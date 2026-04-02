import Foundation
import AppKit
import Combine

@MainActor
class ConversionQueue: ObservableObject {
    @Published var jobs: [ConversionJob] = []
    @Published var isProcessing = false
    @Published var completedCount = 0
    @Published var failedCount = 0
    
    private var activeJobIds: Set<UUID> = []
    private let engine = ConversionEngine.shared
    private var cancellables = Set<AnyCancellable>()
    
    var pendingJobs: [ConversionJob] {
        jobs.filter { $0.status == .pending }
    }
    
    var activeJobs: [ConversionJob] {
        jobs.filter { $0.status == .converting }
    }
    
    var completedJobs: [ConversionJob] {
        jobs.filter { $0.status == .completed }
    }
    
    var failedJobs: [ConversionJob] {
        jobs.filter { $0.status == .failed }
    }
    
    var totalProgress: Double {
        guard !jobs.isEmpty else { return 0 }
        let total = jobs.reduce(0.0) { $0 + $1.progress }
        return total / Double(jobs.count)
    }
    
    func addJobs(urls: [URL], format: FormatPreset) {
        let newJobs = urls.map { url in
            ConversionJob(inputFile: url, outputFormat: format)
        }
        jobs.append(contentsOf: newJobs)
    }
    
    func addJob(url: URL, format: FormatPreset) {
        let job = ConversionJob(inputFile: url, outputFormat: format)
        jobs.append(job)
    }
    
    func removeJob(_ job: ConversionJob) {
        if job.status == .converting {
            engine.cancel(jobId: job.id)
        }
        jobs.removeAll { $0.id == job.id }
    }
    
    func clearCompleted() {
        jobs.removeAll { $0.status == .completed || $0.status == .failed }
        completedCount = 0
        failedCount = 0
    }
    
    func clearAll() {
        engine.cancelAll()
        jobs.removeAll()
        completedCount = 0
        failedCount = 0
        isProcessing = false
        activeJobIds.removeAll()
    }
    
    func cancelJob(_ job: ConversionJob) {
        engine.cancel(jobId: job.id)
        if let index = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[index].status = .cancelled
        }
        activeJobIds.remove(job.id)
    }
    
    func cancelAll() {
        engine.cancelAll()
        for i in jobs.indices {
            if jobs[i].status == .converting || jobs[i].status == .pending {
                jobs[i].status = .cancelled
            }
        }
        activeJobIds.removeAll()
        isProcessing = false
    }
    
    func startProcessing() {
        guard !isProcessing else { return }
        isProcessing = true
        processNextJobs()
    }
    
    private func processNextJobs() {
        let maxConcurrent = Settings.shared.maxConcurrentJobs
        let availableSlots = maxConcurrent - activeJobIds.count
        
        guard availableSlots > 0 else { return }
        
        let jobsToStart = pendingJobs.prefix(availableSlots)
        
        for job in jobsToStart {
            startJob(job)
        }
    }
    
    private func startJob(_ job: ConversionJob) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        
        jobs[index].status = .converting
        jobs[index].startedAt = Date()
        activeJobIds.insert(job.id)
        
        Task {
            do {
                let outputURL = try await engine.convert(job: jobs[index]) { [weak self] progress in
                    Task { @MainActor in
                        guard let self = self, let idx = self.jobs.firstIndex(where: { $0.id == job.id }) else { return }
                        self.jobs[idx].progress = progress
                    }
                }
                
                if let idx = jobs.firstIndex(where: { $0.id == job.id }) {
                    jobs[idx].status = .completed
                    jobs[idx].outputURL = outputURL
                    jobs[idx].completedAt = Date()
                    jobs[idx].progress = 1.0
                    completedCount += 1
                }
            } catch {
                if let idx = jobs.firstIndex(where: { $0.id == job.id }) {
                    jobs[idx].status = .failed
                    jobs[idx].errorMessage = error.localizedDescription
                    jobs[idx].completedAt = Date()
                    failedCount += 1
                }
            }
            
            activeJobIds.remove(job.id)
            
            // Continue processing
            if !pendingJobs.isEmpty {
                processNextJobs()
            } else if activeJobIds.isEmpty {
                isProcessing = false
                handleCompletion()
            }
        }
    }
    
    private func handleCompletion() {
        let settings = Settings.shared
        
        if settings.showInFinderWhenComplete && completedCount > 0 {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: settings.outputDirectory.path)
        }
        
        if settings.playSoundWhenComplete {
            NSSound(named: "Glass")?.play()
        }
    }
    
    func retryJob(_ job: ConversionJob) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        
        jobs[index].status = .pending
        jobs[index].progress = 0
        jobs[index].errorMessage = nil
        jobs[index].startedAt = nil
        jobs[index].completedAt = nil
        
        if !isProcessing {
            startProcessing()
        } else {
            processNextJobs()
        }
    }
    
    func retryAllFailed() {
        for i in jobs.indices where jobs[i].status == .failed {
            jobs[i].status = .pending
            jobs[i].progress = 0
            jobs[i].errorMessage = nil
            jobs[i].startedAt = nil
            jobs[i].completedAt = nil
        }
        failedCount = 0
        
        if !isProcessing {
            startProcessing()
        } else {
            processNextJobs()
        }
    }
}
