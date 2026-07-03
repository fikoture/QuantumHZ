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
        
        // Glass effect colors
        static let glassBackground = Color.white.opacity(0.15)
        static let glassBorder = Color.white.opacity(0.25)
        static let glassHighlight = Color.white.opacity(0.1)
        static let glassShadow = Color.black.opacity(0.2)
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
        
        // Glass effect styles
        static func glassEffect(for sizeClass: UserInterfaceSizeClass?) -> some ViewModifier {
            GlassEffectModifier(sizeClass: sizeClass ?? .compact)
        }
        
        static func glassCard(for sizeClass: UserInterfaceSizeClass?) -> some ViewModifier {
            GlassCardModifier(sizeClass: sizeClass ?? .compact)
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

// Glass Effect Modifiers
struct GlassEffectModifier: ViewModifier {
    let sizeClass: UserInterfaceSizeClass
    
    func body(content: Content) -> some View {
        content
            .padding(10) // Reduce padding for smaller buttons
            .background(
                Circle()
                    .fill(AppTheme.Colors.glassBackground.opacity(0.1))
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            )
            .overlay(
                Circle()
                    .stroke(AppTheme.Colors.glassBorder.opacity(0.5), lineWidth: 0.5)
            )
            .shadow(color: AppTheme.Colors.glassShadow.opacity(0.5), radius: 5, x: 0, y: 3)
    }
}

struct GlassCardModifier: ViewModifier {
    let sizeClass: UserInterfaceSizeClass
    
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Styles.padding(for: sizeClass))
            .background(AppTheme.Colors.glassBackground)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Styles.cornerRadius(for: sizeClass)))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Styles.cornerRadius(for: sizeClass))
                    .stroke(AppTheme.Colors.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: AppTheme.Colors.glassShadow, radius: 15, x: 0, y: 8)
    }
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
    
    // Glass effect modifiers
    func glassEffect(for sizeClass: UserInterfaceSizeClass?) -> some ViewModifier {
        AppTheme.Styles.glassEffect(for: sizeClass)
    }
    
    func glassCard(for sizeClass: UserInterfaceSizeClass?) -> some ViewModifier {
        AppTheme.Styles.glassCard(for: sizeClass)
    }
    
    private init() {}
}

// View Extensions
extension View {
    func glassEffect(for sizeClass: UserInterfaceSizeClass? = nil) -> some View {
        modifier(AppTheme.Styles.glassEffect(for: sizeClass))
    }
    
    func glassCard(for sizeClass: UserInterfaceSizeClass? = nil) -> some View {
        modifier(AppTheme.Styles.glassCard(for: sizeClass))
    }
}
