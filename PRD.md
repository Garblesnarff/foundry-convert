# foundry-convert: Product Requirements Document

## Executive Summary

foundry-convert is the most boring, useful macOS app: drag files, pick format, done. No UI overload, no cloud lock-in. Built for power users, content creators, and developers who convert files 10 times a week.

## Core Features

1. **Drag-Drop Batch Conversion**
   - Multi-select files or folders
   - Recursive folder traversal (optional)
   - Queue progress indicator
   - Cancel individual jobs

2. **Format Selection**
   - Presets: Video (MP4, WebM, MKV, MOV, FLV, AVI)
   - Presets: Audio (MP3, WAV, AAC, FLAC, OGG, OPUS)
   - Presets: Image (JPG, PNG, WebP, TIFF, BMP, GIF)
   - Custom presets (save codec + bitrate combos)

3. **Finder Quick Action**
   - Right-click any file → "Transmute with foundry-convert"
   - Format picker sheet → conversion runs in background
   - Output file opens in Finder

4. **Shortcuts Integration**
   - "Convert file" action with format parameter
   - "Get conversion status" query
   - "Clear conversion history" action

5. **Parallel Processing**
   - Up to 4 concurrent FFmpeg instances
   - Per-job timeout (default 5 minutes)
   - Memory-efficient queue management

## Success Metrics

- 500+ downloads in first month
- 4.5+ stars on App Store
- Average session: 3–5 conversions per user

## Roadmap

- **Phase 1**: Drag-drop, format presets, basic queue
- **Phase 2**: Custom presets, Finder extension, Shortcuts
- **Phase 3**: Watch folder, batch scheduling, advanced filters

---

**Status**: Scaffolding → Phase 1
**Price**: $4.99
