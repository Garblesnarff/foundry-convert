import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
    
    // Foundry design system colors
    static let foundryBackground = Color(hex: "141210")
    static let foundrySurface = Color(hex: "1F1E1D")
    static let foundryCard = Color(hex: "282624")
    static let foundryAccent = Color(hex: "E8A849")
    static let foundryAccentDark = Color(hex: "C4893B")
    static let foundryText = Color(hex: "F5F5F5")
    static let foundryTextSecondary = Color(hex: "888888")
    static let foundrySuccess = Color(hex: "4CAF50")
    static let foundryError = Color(hex: "DC3545")
    static let foundryWarning = Color(hex: "FF9800")
    static let foundryBorder = Color(hex: "3D3B38")
}
