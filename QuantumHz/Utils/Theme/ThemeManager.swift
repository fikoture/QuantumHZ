import SwiftUI

// MARK: - App Theme
struct AppTheme {
    // Colors
    struct Colors {
        static let background = Color("BackgroundColor") // Dark blue (#0D0D1A)
        static let primary = Color("PrimaryColor")       // Turquoise (#5EE6EB)
        static let accent = Color("AccentColor")         // Pink (#FF66C4)
        static let textPrimary = Color.white
        static let textSecondary = Color.gray
    }
    
    // Fonts
    struct Fonts {
        static func title(for sizeClass: UserInterfaceSizeClass?) -> Font {
            sizeClass == .regular ? .system(size: 40, weight: .bold, design: .rounded) : .system(size: 28, weight: .bold, design: .rounded)
        }
        
        static func subtitle(for sizeClass: UserInterfaceSizeClass?) -> Font {
            sizeClass == .regular ? .system(size: 28, weight: .semibold, design: .rounded) : .system(size: 20, weight: .semibold, design: .rounded)
        }
        
        static func body(for sizeClass: UserInterfaceSizeClass?) -> Font {
            sizeClass == .regular ? .system(size: 20, weight: .regular, design: .rounded) : .system(size: 16, weight: .regular, design: .rounded)
        }
    }

    // Styles
    struct Styles {
        static func cornerRadius(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
            sizeClass == .regular ? 30 : 20
        }
        
        static func padding(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
            sizeClass == .regular ? 40 : 20
        }
        
        static func shadow(for sizeClass: UserInterfaceSizeClass?) -> ShadowStyle {
            ShadowStyle(
                color: .black.opacity(0.3),
                radius: sizeClass == .regular ? 15 : 10,
                x: 0,
                y: sizeClass == .regular ? 8 : 5
            )
        }
    }
}

// Helper structure
struct ShadowStyle {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
}

// Theme Manager
class ThemeManager {
    static let shared = ThemeManager()
    
    // Colors
    var primaryColor: Color { AppTheme.Colors.primary }
    var secondaryColor: Color { AppTheme.Colors.accent }
    var backgroundColor: Color { AppTheme.Colors.background }
    
    // Fonts
    func titleFont(for sizeClass: UserInterfaceSizeClass?) -> Font {
        AppTheme.Fonts.title(for: sizeClass)
    }
    
    func subtitleFont(for sizeClass: UserInterfaceSizeClass?) -> Font {
        AppTheme.Fonts.subtitle(for: sizeClass)
    }
    
    func bodyFont(for sizeClass: UserInterfaceSizeClass?) -> Font {
        AppTheme.Fonts.body(for: sizeClass)
    }
    
    // Styles
    func cornerRadius(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        AppTheme.Styles.cornerRadius(for: sizeClass)
    }
    
    func padding(for sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        AppTheme.Styles.padding(for: sizeClass)
    }
    
    func shadow(for sizeClass: UserInterfaceSizeClass?) -> ShadowStyle {
        AppTheme.Styles.shadow(for: sizeClass)
    }
    
    private init() {}
}
