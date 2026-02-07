import SwiftUI
import UIKit

// MARK: - App Theme

/// Centralized theme for the NavigationX Demo App.
/// Provides gradient backgrounds, colors, and styling utilities.
enum AppTheme {
    
    // MARK: - Platform Colors
    
    /// SwiftUI screen accent color (teal/blue family)
    static let swiftUIAccent = Color(red: 0.0, green: 0.75, blue: 0.85)
    
    /// UIKit screen accent color (orange/amber family)
    static let uiKitAccent = Color(red: 1.0, green: 0.55, blue: 0.0)
    
    // MARK: - Screen Gradients (SwiftUI)
    
    enum Gradient {
        static let home = LinearGradient(
            colors: [Color(hex: "0D9488"), Color(hex: "14B8A6"), Color(hex: "2DD4BF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let profile = LinearGradient(
            colors: [Color(hex: "7C3AED"), Color(hex: "8B5CF6"), Color(hex: "A78BFA")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let settings = LinearGradient(
            colors: [Color(hex: "059669"), Color(hex: "10B981"), Color(hex: "34D399")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let dashboard = LinearGradient(
            colors: [Color(hex: "EA580C"), Color(hex: "F97316"), Color(hex: "FB923C")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let messages = LinearGradient(
            colors: [Color(hex: "DB2777"), Color(hex: "EC4899"), Color(hex: "F472B6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let account = LinearGradient(
            colors: [Color(hex: "4F46E5"), Color(hex: "6366F1"), Color(hex: "818CF8")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - UIKit Gradient Colors
    
    enum UIKitGradient {
        static let dashboard: [CGColor] = [
            UIColor(hex: "EA580C").cgColor,
            UIColor(hex: "F97316").cgColor,
            UIColor(hex: "FB923C").cgColor
        ]
        
        static let messages: [CGColor] = [
            UIColor(hex: "DB2777").cgColor,
            UIColor(hex: "EC4899").cgColor,
            UIColor(hex: "F472B6").cgColor
        ]
        
        static let account: [CGColor] = [
            UIColor(hex: "4F46E5").cgColor,
            UIColor(hex: "6366F1").cgColor,
            UIColor(hex: "818CF8").cgColor
        ]
    }
    
    // MARK: - Stack Inspector Styles
    
    enum StackInspector {
        static let backgroundColor = Color.black.opacity(0.3)
        static let headerColor = Color.white.opacity(0.9)
        static let itemBackground = Color.white.opacity(0.15)
        static let swiftUIBadge = Color.blue
        static let uiKitBadge = Color.orange
        static let currentItemBorder = Color.yellow
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - Screen Configuration

/// Configuration for each screen type
struct ScreenConfig {
    let title: String
    let icon: String
    let isSwiftUI: Bool
    let gradient: LinearGradient
    
    // SwiftUI screens
    static let home = ScreenConfig(title: "Home", icon: "house.fill", isSwiftUI: true, gradient: AppTheme.Gradient.home)
    static let profile = ScreenConfig(title: "Profile", icon: "person.fill", isSwiftUI: true, gradient: AppTheme.Gradient.profile)
    static let settings = ScreenConfig(title: "Settings", icon: "gearshape.fill", isSwiftUI: true, gradient: AppTheme.Gradient.settings)
    
    // UIKit screens (shown in SwiftUI context)
    static let dashboard = ScreenConfig(title: "Dashboard", icon: "chart.bar.fill", isSwiftUI: false, gradient: AppTheme.Gradient.dashboard)
    static let messages = ScreenConfig(title: "Messages", icon: "bubble.left.fill", isSwiftUI: false, gradient: AppTheme.Gradient.messages)
    static let account = ScreenConfig(title: "Account", icon: "creditcard.fill", isSwiftUI: false, gradient: AppTheme.Gradient.account)
}
