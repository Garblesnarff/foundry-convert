import Foundation

struct FormatPreset: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let fileExtension: String
    let category: Category
    let ffmpegArgs: [String]
    let isCustom: Bool
    
    init(id: UUID = UUID(), name: String, fileExtension: String, category: Category, ffmpegArgs: [String], isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.fileExtension = fileExtension
        self.category = category
        self.ffmpegArgs = ffmpegArgs
        self.isCustom = isCustom
    }
    
    enum Category: String, Codable, CaseIterable {
        case video = "Video"
        case audio = "Audio"
        case image = "Image"
        
        var icon: String {
            switch self {
            case .video: return "film"
            case .audio: return "music.note"
            case .image: return "photo"
            }
        }
    }
    
    static let videoPresets: [FormatPreset] = [
        FormatPreset(name: "MP4 (H.264)", fileExtension: "mp4", category: .video, ffmpegArgs: ["-c:v", "libx264", "-preset", "medium", "-crf", "23", "-c:a", "aac", "-b:a", "128k"]),
        FormatPreset(name: "MP4 (H.265)", fileExtension: "mp4", category: .video, ffmpegArgs: ["-c:v", "libx265", "-preset", "medium", "-crf", "28", "-c:a", "aac", "-b:a", "128k"]),
        FormatPreset(name: "WebM (VP9)", fileExtension: "webm", category: .video, ffmpegArgs: ["-c:v", "libvpx-vp9", "-crf", "30", "-b:v", "0", "-c:a", "libopus", "-b:a", "128k"]),
        FormatPreset(name: "MKV", fileExtension: "mkv", category: .video, ffmpegArgs: ["-c:v", "libx264", "-preset", "medium", "-crf", "23", "-c:a", "aac", "-b:a", "128k"]),
        FormatPreset(name: "MOV", fileExtension: "mov", category: .video, ffmpegArgs: ["-c:v", "libx264", "-preset", "medium", "-crf", "23", "-c:a", "aac", "-b:a", "128k"]),
        FormatPreset(name: "FLV", fileExtension: "flv", category: .video, ffmpegArgs: ["-c:v", "libx264", "-preset", "medium", "-crf", "23", "-c:a", "aac", "-b:a", "128k"]),
        FormatPreset(name: "AVI", fileExtension: "avi", category: .video, ffmpegArgs: ["-c:v", "libx264", "-preset", "medium", "-crf", "23", "-c:a", "mp3", "-b:a", "128k"])
    ]
    
    static let audioPresets: [FormatPreset] = [
        FormatPreset(name: "MP3", fileExtension: "mp3", category: .audio, ffmpegArgs: ["-c:a", "libmp3lame", "-b:a", "192k"]),
        FormatPreset(name: "WAV", fileExtension: "wav", category: .audio, ffmpegArgs: ["-c:a", "pcm_s16le"]),
        FormatPreset(name: "AAC", fileExtension: "m4a", category: .audio, ffmpegArgs: ["-c:a", "aac", "-b:a", "256k"]),
        FormatPreset(name: "FLAC", fileExtension: "flac", category: .audio, ffmpegArgs: ["-c:a", "flac"]),
        FormatPreset(name: "OGG", fileExtension: "ogg", category: .audio, ffmpegArgs: ["-c:a", "libvorbis", "-b:a", "192k"]),
        FormatPreset(name: "Opus", fileExtension: "opus", category: .audio, ffmpegArgs: ["-c:a", "libopus", "-b:a", "128k"])
    ]
    
    static let imagePresets: [FormatPreset] = [
        FormatPreset(name: "JPG", fileExtension: "jpg", category: .image, ffmpegArgs: ["-q:v", "5"]),
        FormatPreset(name: "PNG", fileExtension: "png", category: .image, ffmpegArgs: ["-compression_level", "6"]),
        FormatPreset(name: "WebP", fileExtension: "webp", category: .image, ffmpegArgs: ["-c:v", "libwebp", "-q:v", "80"]),
        FormatPreset(name: "TIFF", fileExtension: "tiff", category: .image, ffmpegArgs: ["-c:v", "tiff"]),
        FormatPreset(name: "BMP", fileExtension: "bmp", category: .image, ffmpegArgs: ["-c:v", "bmp"]),
        FormatPreset(name: "GIF", fileExtension: "gif", category: .image, ffmpegArgs: ["-c:v", "gif"])
    ]
    
    static let allPresets: [FormatPreset] = videoPresets + audioPresets + imagePresets
    
    static func `default`(for category: Category) -> FormatPreset {
        switch category {
        case .video: return videoPresets.first!
        case .audio: return audioPresets.first!
        case .image: return imagePresets.first!
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FormatPreset, rhs: FormatPreset) -> Bool {
        lhs.id == rhs.id
    }
}
