import SwiftUI

@main
struct FoundryConvertApp: App {
    @StateObject private var conversionQueue = ConversionQueue()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(conversionQueue)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            // File menu
            CommandGroup(replacing: .newItem) {
                Button("Add Files...") {
                    NotificationCenter.default.post(name: .openFilePicker, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            CommandGroup(after: .newItem) {
                Divider()
                
                Button("Clear Queue") {
                    conversionQueue.clearAll()
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
            }
            
            // Edit menu
            CommandGroup(replacing: .undoRedo) {
                Button("Retry Failed") {
                    conversionQueue.retryAllFailed()
                }
                .disabled(conversionQueue.failedJobs.isEmpty)
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            
            // View menu
            CommandGroup(after: .toolbar) {
                Button("Show Output Folder") {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: Settings.shared.outputDirectory.path)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
        
        // Settings window
        SwiftUI.Settings {
            SettingsPanel()
        }
    }
}

extension Notification.Name {
    static let openFilePicker = Notification.Name("openFilePicker")
}

#Preview {
    ContentView()
        .environmentObject(ConversionQueue())
}
