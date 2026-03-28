import SwiftUI
import UniformTypeIdentifiers

struct DropZone: View {
    @Binding var droppedFiles: [URL]
    @Binding var selectedFormat: FormatPreset?
    @State private var isTargeted = false
    @State private var isHovering = false
    
    let onFilesDropped: ([URL]) -> Void
    
    private let supportedTypes: [UTType] = [
        .movie, .video, .audio, .image, .mpeg4Movie, .quickTimeMovie,
        .mp3, .wav, .aiff, .aiff, .midi, .pdf,
        .jpeg, .png, .tiff, .gif, .bmp, .heic, .webP,
        .item // Fallback for any file
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: isTargeted ? "flame.fill" : "flame")
                .font(.system(size: 48))
                .foregroundColor(isTargeted ? .foundryAccent : .foundryAccent.opacity(0.6))
                .scaleEffect(isTargeted ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: isTargeted)
            
            // Main text
            VStack(spacing: 4) {
                Text(isTargeted ? "Release to Forge" : "Drop Raw Materials")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(isTargeted ? .foundryAccent : .foundryText)
                
                Text("or click to browse")
                    .font(.system(size: 14))
                    .foregroundColor(.foundryTextSecondary)
            }
            
            // Supported formats hint
            HStack(spacing: 8) {
                Label("Video", systemImage: "film")
                Label("Audio", systemImage: "music.note")
                Label("Image", systemImage: "photo")
            }
            .font(.system(size: 11))
            .foregroundColor(.foundryTextSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isTargeted ? Color.foundryAccent.opacity(0.1) : Color.foundrySurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isTargeted ? Color.foundryAccent : Color.foundryBorder,
                            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                        )
                )
        )
        .contentShape(Rectangle())
        .onDrop(of: supportedTypes, isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onTapGesture {
            openFilePicker()
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Drop zone for files to convert")
        .accessibilityHint("Drop files here or click to browse")
        .accessibilityAddTraits(.isButton)
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    // Check if it's a directory
                    var isDirectory: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            // Recursively add files from directory
                            if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                                for case let fileURL as URL in enumerator {
                                    urls.append(fileURL)
                                }
                            }
                        } else {
                            urls.append(url)
                        }
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !urls.isEmpty {
                onFilesDropped(urls)
            }
        }
    }
    
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowedContentTypes = supportedTypes
        panel.message = "Select files to transmute"
        panel.prompt = "Add to Forge"
        
        if panel.runModal() == .OK {
            var urls: [URL] = []
            for url in panel.urls {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                            for case let fileURL as URL in enumerator {
                                urls.append(fileURL)
                            }
                        }
                    } else {
                        urls.append(url)
                    }
                }
            }
            if !urls.isEmpty {
                onFilesDropped(urls)
            }
        }
    }
}

#Preview {
    DropZone(droppedFiles: .constant([]), selectedFormat: .constant(nil), onFilesDropped: { _ in })
        .padding()
        .background(Color.foundryBackground)
}
