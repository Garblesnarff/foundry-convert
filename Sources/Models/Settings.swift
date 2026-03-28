import Foundation
import Combine

class Settings: ObservableObject {
    static let shared = Settings()
    
    @Published var outputDirectory: URL {
        didSet {
            UserDefaults.standard.set(outputDirectory.path, forKey: Keys.outputDirectory)
        }
    }
    
    @Published var maxConcurrentJobs: Int {
        didSet {
            UserDefaults.standard.set(maxConcurrentJobs, forKey: Keys.maxConcurrentJobs)
        }
    }
    
    @Published var jobTimeout: TimeInterval {
        didSet {
            UserDefaults.standard.set(jobTimeout, forKey: Keys.jobTimeout)
        }
    }
    
    @Published var preserveMetadata: Bool {
        didSet {
            UserDefaults.standard.set(preserveMetadata, forKey: Keys.preserveMetadata)
        }
    }
    
    @Published var overwriteExisting: Bool {
        didSet {
            UserDefaults.standard.set(overwriteExisting, forKey: Keys.overwriteExisting)
        }
    }
    
    @Published var showInFinderWhenComplete: Bool {
        didSet {
            UserDefaults.standard.set(showInFinderWhenComplete, forKey: Keys.showInFinderWhenComplete)
        }
    }
    
    @Published var playSoundWhenComplete: Bool {
        didSet {
            UserDefaults.standard.set(playSoundWhenComplete, forKey: Keys.playSoundWhenComplete)
        }
    }
    
    private init() {
        let defaultOutput = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("FoundryConvert")

        let outputDir = URL(fileURLWithPath: UserDefaults.standard.string(forKey: Keys.outputDirectory) ?? defaultOutput.path)
        var concurrent = UserDefaults.standard.integer(forKey: Keys.maxConcurrentJobs)
        if concurrent == 0 { concurrent = 4 }
        var timeout = UserDefaults.standard.double(forKey: Keys.jobTimeout)
        if timeout == 0 { timeout = 300 }
        var showInFinder = UserDefaults.standard.bool(forKey: Keys.showInFinderWhenComplete)
        if !UserDefaults.standard.bool(forKey: Keys.hasLaunchedBefore) {
            showInFinder = true
        }

        self.outputDirectory = outputDir
        self.maxConcurrentJobs = concurrent
        self.jobTimeout = timeout
        self.preserveMetadata = UserDefaults.standard.bool(forKey: Keys.preserveMetadata)
        self.overwriteExisting = UserDefaults.standard.bool(forKey: Keys.overwriteExisting)
        self.showInFinderWhenComplete = showInFinder
        self.playSoundWhenComplete = UserDefaults.standard.bool(forKey: Keys.playSoundWhenComplete)

        // Ensure output directory exists
        try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

        // Mark as launched
        UserDefaults.standard.set(true, forKey: Keys.hasLaunchedBefore)
    }
    
    private enum Keys {
        static let outputDirectory = "outputDirectory"
        static let maxConcurrentJobs = "maxConcurrentJobs"
        static let jobTimeout = "jobTimeout"
        static let preserveMetadata = "preserveMetadata"
        static let overwriteExisting = "overwriteExisting"
        static let showInFinderWhenComplete = "showInFinderWhenComplete"
        static let playSoundWhenComplete = "playSoundWhenComplete"
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }
    
    func resetToDefaults() {
        let defaultOutput = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop")
            .appendingPathComponent("FoundryConvert")
        
        outputDirectory = defaultOutput
        maxConcurrentJobs = 4
        jobTimeout = 300
        preserveMetadata = false
        overwriteExisting = false
        showInFinderWhenComplete = true
        playSoundWhenComplete = false
    }
}
