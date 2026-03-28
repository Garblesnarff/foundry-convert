import SwiftUI

struct SettingsPanel: View {
    @ObservedObject var settings = Settings.shared
    @State private var showFolderPicker = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Forge Settings")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.foundryText)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.foundryTextSecondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .background(Color.foundryBorder)
            
            // Output directory
            VStack(alignment: .leading, spacing: 8) {
                Text("Output Workshop")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.foundryText)
                
                HStack {
                    Text(settings.outputDirectory.path)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.foundryTextSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Button("Choose...") {
                        openFolderPicker()
                    }
                    .buttonStyle(.bordered)
                    .tint(.foundryAccent)
                }
                .padding(10)
                .background(Color.foundryCard)
                .cornerRadius(6)
            }
            
            // Performance settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.foundryText)
                
                HStack {
                    Text("Concurrent forges")
                        .font(.system(size: 12))
                        .foregroundColor(.foundryTextSecondary)
                    
                    Spacer()
                    
                    Picker("", selection: $settings.maxConcurrentJobs) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
            }
            
            // Behavior settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Behavior")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.foundryText)
                
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Show in Finder when complete", isOn: $settings.showInFinderWhenComplete)
                        .toggleStyle(.checkbox)
                    
                    Toggle("Play sound when complete", isOn: $settings.playSoundWhenComplete)
                        .toggleStyle(.checkbox)
                    
                    Toggle("Overwrite existing files", isOn: $settings.overwriteExisting)
                        .toggleStyle(.checkbox)
                    
                    Toggle("Preserve metadata", isOn: $settings.preserveMetadata)
                        .toggleStyle(.checkbox)
                }
                .font(.system(size: 12))
                .foregroundColor(.foundryText)
            }
            
            Divider()
                .background(Color.foundryBorder)
            
            // Footer
            HStack {
                Button("Reset to Defaults") {
                    settings.resetToDefaults()
                }
                .buttonStyle(.bordered)
                .tint(.foundryTextSecondary)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.foundryAccent)
            }
        }
        .padding(20)
        .frame(width: 400)
        .background(Color.foundrySurface)
        .cornerRadius(12)
    }
    
    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select output folder for forged files"
        panel.prompt = "Select"
        
        if panel.runModal() == .OK, let url = panel.url {
            settings.outputDirectory = url
        }
    }
}

#Preview {
    SettingsPanel()
        .background(Color.foundryBackground)
}
