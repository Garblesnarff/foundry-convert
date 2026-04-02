import SwiftUI

struct ContentView: View {
    @EnvironmentObject var queue: ConversionQueue
    @State private var droppedFiles: [URL] = []
    @State private var selectedFormat: FormatPreset? = FormatPreset.videoPresets.first
    @State private var showSettings = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            ScrollView {
                VStack(spacing: 24) {
                    // Drop zone
                    DropZone(
                        droppedFiles: $droppedFiles,
                        selectedFormat: $selectedFormat,
                        onFilesDropped: handleFilesDropped
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // Format selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Output Format")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.foundryText)
                            .padding(.horizontal, 24)
                        
                        FormatSelector(selectedFormat: $selectedFormat)
                            .padding(.horizontal, 24)
                    }
                    
                    // Progress queue
                    ProgressQueue(queue: queue)
                        .padding(.horizontal, 24)
                    
                    // Action buttons
                    if !droppedFiles.isEmpty || !queue.jobs.isEmpty {
                        actionButtons
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(Color.foundryBackground)
        .frame(minWidth: 600, minHeight: 500)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    openFilePicker()
                } label: {
                    Label("Open", systemImage: "folder.badge.plus")
                }
                .help("Add files to queue (⌘O)")
                .keyboardShortcut("o", modifiers: .command)
                
                Button {
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .help("Open settings (⌘,)")
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsPanel()
        }
        .onChange(of: queue.completedCount) { _ in
            if queue.completedCount > 0 && !queue.isProcessing {
                showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccessMessage = false
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showSuccessMessage {
                successBanner
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            // Set default format
            if selectedFormat == nil {
                selectedFormat = FormatPreset.videoPresets.first
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // File count
            if !droppedFiles.isEmpty {
                Text("\(droppedFiles.count) file\(droppedFiles.count == 1 ? "" : "s") selected")
                    .font(.system(size: 12))
                    .foregroundColor(.foundryTextSecondary)
            }
            
            Spacer()
            
            // Clear button
            if !queue.jobs.isEmpty {
                Button {
                    queue.clearAll()
                    droppedFiles.removeAll()
                } label: {
                    Text("Clear All")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(.foundryTextSecondary)
            }
            
            // Transmute button
            Button {
                startConversion()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: queue.isProcessing ? "flame" : "flame.fill")
                    Text(queue.isProcessing ? "Forging..." : "Transmute")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.foundryBackground)
            }
            .buttonStyle(.borderedProminent)
            .tint(.foundryAccent)
            .disabled(droppedFiles.isEmpty && queue.jobs.isEmpty)
            .disabled(queue.isProcessing && queue.pendingJobs.isEmpty)
            .keyboardShortcut(.return, modifiers: .command)
        }
        .padding(16)
        .background(Color.foundrySurface)
        .cornerRadius(12)
    }
    
    private var successBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.foundrySuccess)
            
            Text("Forging complete!")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.foundryText)
            
            Button {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: Settings.shared.outputDirectory.path)
            } label: {
                Text("Show in Finder")
                    .font(.system(size: 12))
            }
            .buttonStyle(.bordered)
            .tint(.foundryAccent)
        }
        .padding(12)
        .background(Color.foundryCard)
        .cornerRadius(8)
        .padding(.bottom, 16)
    }
    
    private func handleFilesDropped(_ urls: [URL]) {
        droppedFiles.append(contentsOf: urls)
        
        // If format selected, add to queue immediately
        if let format = selectedFormat {
            queue.addJobs(urls: urls, format: format)
            droppedFiles.removeAll()
        }
    }
    
    private func startConversion() {
        if !droppedFiles.isEmpty, let format = selectedFormat {
            queue.addJobs(urls: droppedFiles, format: format)
            droppedFiles.removeAll()
        }
        
        if !queue.isProcessing {
            queue.startProcessing()
        }
    }
    
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.movie, .video, .audio, .image, .mpeg4Movie, .quickTimeMovie, .mp3, .wav, .item]
        panel.message = "Select files to transmute"
        panel.prompt = "Add to Forge"
        
        if panel.runModal() == .OK {
            handleFilesDropped(panel.urls)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ConversionQueue())
}
