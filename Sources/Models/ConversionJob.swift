import Foundation

struct ConversionJob: Identifiable, Equatable {
    let id = UUID()
    let inputFile: URL
    let outputFormat: FormatPreset
    var progress: Double = 0
    var status: Status = .pending
    var outputURL: URL?
    var errorMessage: String?
    var startedAt: Date?
    var completedAt: Date?
    
    enum Status: String {
        case pending = "Awaiting Forge"
        case converting = "Transmuting"
        case completed = "Forged"
        case failed = "Failed"
        case cancelled = "Cancelled"
    }
    
    var inputFileName: String {
        inputFile.lastPathComponent
    }
    
    var outputFileName: String {
        let baseName = inputFile.deletingPathExtension().lastPathComponent
        return "\(baseName).\(outputFormat.fileExtension)"
    }
    
    var duration: TimeInterval? {
        guard let start = startedAt, let end = completedAt else { return nil }
        return end.timeIntervalSince(start)
    }
    
    static func == (lhs: ConversionJob, rhs: ConversionJob) -> Bool {
        lhs.id == rhs.id
    }
}
