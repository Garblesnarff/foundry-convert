# foundry-convert

Batch media converter. Transmute images, videos, and audio formats instantly.

## Status

**Phase 1 MVP: Complete** ✅

A fully functional batch media converter with drag-drop interface, parallel processing, and forge-themed UI.

## Features

- ✅ Drag-drop batch conversion
- ✅ 19 format presets across video, audio, and image categories
- ✅ Parallel processing (up to 4 simultaneous conversions)
- ✅ Real-time progress tracking per file
- ✅ Configurable output directory
- ✅ Settings persistence with UserDefaults
- ✅ Dark-only forge aesthetic UI
- ✅ Keyboard shortcuts (⌘O, ⌘,, ⌘↩)
- ✅ Accessibility labels throughout
- 🚧 Custom presets (Phase 2)
- 🚧 Finder Quick Action (Phase 2)
- 🚧 Shortcuts integration (Phase 2)

## Quick Start

```bash
# Open in Xcode
open FoundryConvert.xcodeproj

# Build (requires Xcode 15+)
xcodebuild -project FoundryConvert.xcodeproj -scheme FoundryConvert -configuration Release

# Run
open ./build/Release/FoundryConvert.app
```

## Requirements

- macOS 13.0+ (Ventura)
- Apple Silicon (arm64) optimized
- FFmpeg (bundled or system install at `/opt/homebrew/bin/ffmpeg`)

## Formats Supported

**Video**: MP4 (H.264/H.265), WebM (VP9), MKV, MOV, FLV, AVI
**Audio**: MP3, WAV, AAC, FLAC, OGG, Opus
**Image**: JPG, PNG, WebP, TIFF, BMP, GIF

## Usage

1. Open foundry-convert
2. Drag files into the forge zone (or click to browse, ⌘O)
3. Select output format (Video/Audio/Image tabs)
4. Click "Transmute" (⌘↵)
5. Files saved to `~/Desktop/FoundryConvert/` by default

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘O | Open file picker |
| ⌘, | Open settings |
| ⌘↵ | Start conversion |
| ⇧⌘R | Retry all failed jobs |
| ⇧⌘O | Show output folder in Finder |
| ⇧⌘⌫ | Clear queue |

## Project Structure

```
FoundryConvert/
├── Sources/
│   ├── FoundryConvertApp.swift    # App entry point, menu commands
│   ├── Views/
│   │   ├── ContentView.swift      # Main layout
│   │   ├── DropZone.swift         # Drag-drop interface
│   │   ├── FormatSelector.swift   # Format picker with category tabs
│   │   ├── ProgressQueue.swift    # Job list with progress
│   │   └── SettingsPanel.swift    # Configuration panel
│   ├── Conversion/
│   │   ├── ConversionEngine.swift # FFmpeg wrapper
│   │   └── ConversionQueue.swift  # FIFO dispatcher, parallel processing
│   ├── Models/
│   │   ├── ConversionJob.swift    # Job model
│   │   ├── FormatPreset.swift     # Format definitions with FFmpeg args
│   │   └── Settings.swift         # User preferences
│   └── Extensions/
│       └── Color+Hex.swift        # Foundry color palette
├── Resources/
│   ├── Assets.xcassets/           # App icon (placeholder)
│   ├── Info.plist                 # Bundle configuration
│   └── FoundryConvert.entitlements # App sandbox
├── FoundryConvert.xcodeproj/      # Xcode project
└── docs/
    ├── DESIGN_SYSTEM.md           # Color/typography specs
    └── ICON_DESIGN.md             # App icon brief

```

## Design System

- **Background**: Charcoal (#141210)
- **Surface**: Dark charcoal (#1F1E1D)
- **Accent**: Forge amber (#E8A849)
- **Success**: Green (#4CAF50)
- **Error**: Red (#DC3545)
- **Text**: Light (#F5F5F5) / Secondary (#888888)

All UI text uses forge/metallurgy terminology (transmute, forge, raw materials, etc.)

## License

MIT. See LICENSE.
