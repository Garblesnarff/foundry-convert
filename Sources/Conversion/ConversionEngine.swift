import Foundation
import Combine

class ConversionEngine {
    static let shared = ConversionEngine()
    
    private var activeProcesses: [UUID: Process] = [:]
    private let processLock = NSLock()
    
    enum ConversionError: LocalizedError {
        case ffmpegNotFound
        case invalidInputFile
        case outputDirectoryNotFound
        case processFailed(String)
        case timeout
        case cancelled
        
        var errorDescription: String? {
            switch self {
            case .ffmpegNotFound:
                return "Forge fire unavailable—FFmpeg binary not found"
            case .invalidInputFile:
                return "Invalid raw material—input file cannot be read"
            case .outputDirectoryNotFound:
                return "Workshop not ready—output directory unavailable"
            case .processFailed(let message):
                return "Transmutation failed: \(message)"
            case .timeout:
                return "Forge cooled—conversion timed out"
            case .cancelled:
                return "Work cancelled by smith"
            }
        }
    }
    
    private var ffmpegPath: String {
        // Check for bundled FFmpeg first, then system
        let bundledPath = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Resources/ffmpeg")
            .path
        
        if FileManager.default.fileExists(atPath: bundledPath) {
            return bundledPath
        }
        
        // Fall back to system FFmpeg (for development)
        return "/opt/homebrew/bin/ffmpeg"
    }
    
    func convert(job: ConversionJob, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        // Verify FFmpeg exists
        guard FileManager.default.fileExists(atPath: ffmpegPath) else {
            throw ConversionError.ffmpegNotFound
        }
        
        // Verify input file exists
        guard FileManager.default.fileExists(atPath: job.inputFile.path) else {
            throw ConversionError.invalidInputFile
        }
        
        // Get output directory
        let settings = Settings.shared
        let outputDir = settings.outputDirectory
        
        // Ensure output directory exists
        if !FileManager.default.fileExists(atPath: outputDir.path) {
            try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        }
        
        // Build output URL
        let outputURL = outputDir.appendingPathComponent(job.outputFileName)
        
        // Check if file exists and handle overwrite
        if FileManager.default.fileExists(atPath: outputURL.path) && !settings.overwriteExisting {
            let baseName = job.inputFile.deletingPathExtension().lastPathComponent
            let timestamp = ISO8601DateFormatter().string(from: Date())
                .replacingOccurrences(of: ":", with: "-")
                .replacingOccurrences(of: "+", with: "-")
            let newName = "\(baseName)_\(timestamp).\(job.outputFormat.fileExtension)"
            return try await performConversion(job: job, outputURL: outputDir.appendingPathComponent(newName), progressHandler: progressHandler)
        }
        
        return try await performConversion(job: job, outputURL: outputURL, progressHandler: progressHandler)
    }
    
    private func performConversion(job: ConversionJob, outputURL: URL, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: ffmpegPath)
        
        // Build arguments
        var arguments = ["-i", job.inputFile.path]
        arguments.append(contentsOf: job.outputFormat.ffmpegArgs)
        
        if Settings.shared.preserveMetadata {
            arguments.append("-map_metadata")
            arguments.append("0")
        }
        
        arguments.append("-y") // Overwrite output files
        arguments.append(outputURL.path)
        
        process.arguments = arguments
        
        // Capture output for error handling
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Track process for cancellation
        processLock.lock()
        activeProcesses[job.id] = process
        processLock.unlock()
        
        // Setup progress monitoring
        let progressTask = Task {
            await monitorProgress(process: process, errorPipe: errorPipe, progressHandler: progressHandler)
        }
        
        do {
            try process.run()
            process.waitUntilExit()
            
            progressTask.cancel()
            
            // Remove from active processes
            processLock.lock()
            activeProcesses.removeValue(forKey: job.id)
            processLock.unlock()
            
            if process.terminationStatus == 0 {
                // Verify output file exists
                guard FileManager.default.fileExists(atPath: outputURL.path) else {
                    throw ConversionError.processFailed("Output file was not created")
                }
                return outputURL
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                throw ConversionError.processFailed(errorMessage)
            }
        } catch {
            progressTask.cancel()
            
            processLock.lock()
            activeProcesses.removeValue(forKey: job.id)
            processLock.unlock()
            
            if let conversionError = error as? ConversionError {
                throw conversionError
            }
            throw ConversionError.processFailed(error.localizedDescription)
        }
    }
    
    private func monitorProgress(process: Process, errorPipe: Pipe, progressHandler: @escaping (Double) -> Void) async {
        // Parse FFmpeg progress from stderr
        let handle = errorPipe.fileHandleForReading
        var duration: Double = 0
        
        while process.isRunning {
            let data = handle.availableData
            guard let output = String(data: data, encoding: .utf8) else { continue }
            
            // Parse duration from "Duration: HH:MM:SS.mm" line
            if duration == 0, let durationRange = output.range(of: "Duration: ") {
                let durationStr = String(output[durationRange.upperBound...])
                if let endBracket = durationStr.firstIndex(of: ",") {
                    let timeStr = String(durationStr[..<endBracket]).trimmingCharacters(in: .whitespaces)
                    duration = parseTime(timeStr)
                }
            }
            
            // Parse current time from "frame=   XX fps=YY time=HH:MM:SS.mm" line
            if duration > 0, let timeRange = output.range(of: "time=") {
                let timeStr = String(output[timeRange.upperBound...])
                if let spaceIndex = timeStr.firstIndex(of: " ") {
                    let currentTime = parseTime(String(timeStr[..<spaceIndex]))
                    let progress = min(currentTime / duration, 1.0)
                    await MainActor.run {
                        progressHandler(progress)
                    }
                }
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        }
    }
    
    private func parseTime(_ timeString: String) -> Double {
        let components = timeString.split(separator: ":")
        guard components.count >= 2 else { return 0 }
        
        var hours: Double = 0
        var minutes: Double = 0
        var seconds: Double = 0
        
        if components.count == 3 {
            hours = Double(components[0]) ?? 0
            minutes = Double(components[1]) ?? 0
            seconds = Double(components[2]) ?? 0
        } else if components.count == 2 {
            minutes = Double(components[0]) ?? 0
            seconds = Double(components[1]) ?? 0
        }
        
        return hours * 3600 + minutes * 60 + seconds
    }
    
    func cancel(jobId: UUID) {
        processLock.lock()
        if let process = activeProcesses[jobId] {
            process.terminate()
            activeProcesses.removeValue(forKey: jobId)
        }
        processLock.unlock()
    }
    
    func cancelAll() {
        processLock.lock()
        for (_, process) in activeProcesses {
            process.terminate()
        }
        activeProcesses.removeAll()
        processLock.unlock()
    }
}
