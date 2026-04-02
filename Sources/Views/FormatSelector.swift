import SwiftUI

struct FormatSelector: View {
    @Binding var selectedFormat: FormatPreset?
    @State private var selectedCategory: FormatPreset.Category = .video
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Category tabs
            HStack(spacing: 0) {
                ForEach(FormatPreset.Category.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedCategory == category ? Color.foundryAccent : Color.clear)
                        .foregroundColor(selectedCategory == category ? .foundryBackground : .foundryTextSecondary)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Color.foundrySurface)
            .cornerRadius(10)
            
            // Format grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(formatsForCategory) { format in
                        FormatButton(
                            format: format,
                            isSelected: selectedFormat?.id == format.id
                        ) {
                            selectedFormat = format
                        }
                    }
                }
                .padding(4)
            }
            .frame(maxHeight: 200)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Format selector")
    }
    
    private var formatsForCategory: [FormatPreset] {
        switch selectedCategory {
        case .video: return FormatPreset.videoPresets
        case .audio: return FormatPreset.audioPresets
        case .image: return FormatPreset.imagePresets
        }
    }
}

struct FormatButton: View {
    let format: FormatPreset
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(format.fileExtension.uppercased())
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? .foundryBackground : .foundryText)
                
                Text(format.name)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .foundryBackground.opacity(0.7) : .foundryTextSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.foundryAccent : Color.foundryCard)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.foundryAccent : Color.foundryBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(format.name)
        .accessibilityHint(isSelected ? "Selected" : "Tap to select")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    FormatSelector(selectedFormat: .constant(nil))
        .padding()
        .background(Color.foundryBackground)
        .frame(width: 400)
}
