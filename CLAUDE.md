# foundry-convert: Batch File Converter

## What This Is

**foundry-convert** is a native macOS batch media converter. Drag images/videos/audio into the forge, select output format, and transmute them instantly. No subscriptions, no cloud, no complexity. Finder Quick Action + Shortcuts integration for seamless workflows.

## Tech Stack

- **Runtime**: Swift 5.9
- **UI**: SwiftUI (native macOS app)
- **Formats**: FFmpeg (bundled binary)
- **Architecture**: Multi-threaded queue processing
- **Target**: macOS 13.0+ Apple Silicon

## Architecture

```
┌──────────────────────────────┐
│   SwiftUI Main Window        │
│  • Drag-drop zone            │
│  • Format selector           │
│  • Custom presets panel      │
│  • Progress queue            │
└──────────┬───────────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼──────┐  ┌──▼────────────┐
│ Finder   │  │ Shortcuts App  │
│Extension │  │ Integration    │
└───┬──────┘  └──┬─────────────┘
    │            │
    └──────┬─────┘
           │
    ┌──────▼──────────────┐
    │ Conversion Queue    │
    │ (FIFO dispatcher)   │
    └──────┬──────────────┘
           │
    ┌──────▼──────────────┐
    │ FFmpeg Process Pool │
    │ (parallelized)      │
    └──────┬──────────────┘
           │
    ┌──────▼──────────────┐
    │ Output Directory    │
    │ (organized by type) │
    └────────────────────┘
```

## Core Features

1. **Drag-Drop Batch Conversion**
   - Multi-file selection
   - Folder recursion (optional)
   - Progress queue UI

2. **Format Presets**
   - Video: MP4, WebM, MKV, MOV
   - Audio: MP3, WAV, AAC, FLAC, OGG
   - Image: JPG, PNG, WebP, TIFF, GIF

3. **Custom Presets**
   - Save codec + bitrate + quality combos
   - Library of community presets
   - Per-file override

4. **Finder Quick Action**
   - Right-click file → "Transmute with foundry-convert"
   - Shortcut: Format picker → conversion runs in background

5. **Shortcuts Integration**
   - Query foundry-convert conversion status
   - Trigger batch conversions with custom settings
   - Chain with other shortcuts

## File Structure

```
Sources/
├── FoundryConvertApp.swift
├── Views/
│   ├── DropZone.swift
│   ├── FormatSelector.swift
│   ├── PresetManager.swift
│   ├── ProgressQueue.swift
│   └── SettingsPanel.swift
├── Conversion/
│   ├── ConversionEngine.swift      # FFmpeg wrapper
│   ├── FormatPresets.swift         # Built-in + custom
│   ├── ConversionQueue.swift       # FIFO dispatcher
│   └── ProcessPool.swift           # Parallel FFmpeg instances
├── Models/
│   ├── ConversionJob.swift
│   └── Settings.swift
└── Extensions/
    └── FileManager+Extensions.swift

docs/
├── DESIGN_SYSTEM.md
├── ARCHITECTURE.md
└── BUILD.md

README.md
PRD.md
TODO.md
CLAUDE.md
AGENTS.md
```

## Build & Run

```bash
# Build
xcodebuild -scheme FoundryConvert -configuration Release

# Run
open ./build/Release/FoundryConvert.app
```

## Legal

- **Code**: MIT (original implementation)
- **FFmpeg**: LGPL-2.1 (bundled dynamically)
- Provides attribution in About dialog

## Performance

- **Single File**: 5–120 seconds (depends on codec/resolution)
- **Parallel**: Up to 4 simultaneous FFmpeg processes
- **Memory**: ~500 MB per conversion + base overhead

---

**Last Updated**: 2026-03-15
**Status**: Scaffolding
**Price**: $4.99 (undercut DaisyDisk, simpler feature set)
