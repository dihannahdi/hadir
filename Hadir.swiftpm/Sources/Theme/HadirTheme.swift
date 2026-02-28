import SwiftUI

// MARK: - Hadir Design System: "Tanah dan Cahaya"
// Visual philosophy inspired by Indonesian nature — warm, trustworthy, grounded

enum HadirTheme {
    
    // MARK: - Colors
    
    /// Primary — Emerald: Trust, health, Indonesian tropical forests
    static let emerald = Color(red: 13/255, green: 107/255, blue: 79/255)       // #0D6B4F
    
    /// Alert / Red Flag — Terracotta: Urgency without panic, firm earth tone
    static let terracotta = Color(red: 192/255, green: 88/255, blue: 58/255)    // #C0583A
    
    /// Background — Cream: Warm, eye-friendly, not sterile white
    static let cream = Color(red: 247/255, green: 243/255, blue: 238/255)       // #F7F3EE
    
    /// Text primary — Deep charcoal
    static let textPrimary = Color(red: 38/255, green: 38/255, blue: 38/255)    // #262626
    
    /// Text secondary — Warm gray
    static let textSecondary = Color(red: 115/255, green: 110/255, blue: 105/255) // #736E69
    
    /// Doctor speaker color
    static let doctorColor = Color(red: 30/255, green: 90/255, blue: 145/255)   // #1E5A91
    
    /// Patient speaker color
    static let patientColor = Color(red: 140/255, green: 70/255, blue: 20/255)  // #8C4614
    
    /// Card background
    static let cardBackground = Color.white
    
    /// Subtle border
    static let border = Color(red: 220/255, green: 215/255, blue: 210/255)      // #DCD7D2
    
    /// Success green
    static let success = Color(red: 34/255, green: 139/255, blue: 34/255)       // #228B22
    
    /// Emerald light (for highlights)
    static let emeraldLight = Color(red: 13/255, green: 107/255, blue: 79/255).opacity(0.15)
    
    /// Terracotta light (for alert backgrounds)
    static let terracottaLight = Color(red: 192/255, green: 88/255, blue: 58/255).opacity(0.12)
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // MARK: - Corner Radius
    
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 24
    
    // MARK: - Shadow
    
    static let shadowColor = Color.black.opacity(0.06)
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 4
}

// MARK: - Custom View Modifiers

struct HadirCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(HadirTheme.spacingMD)
            .background(HadirTheme.cardBackground)
            .cornerRadius(HadirTheme.radiusMD)
            .shadow(color: HadirTheme.shadowColor, radius: HadirTheme.shadowRadius, y: HadirTheme.shadowY)
    }
}

struct HadirPrimaryButtonModifier: ViewModifier {
    var isDisabled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, HadirTheme.spacingXL)
            .padding(.vertical, HadirTheme.spacingMD)
            .background(isDisabled ? HadirTheme.textSecondary : HadirTheme.emerald)
            .cornerRadius(HadirTheme.radiusXL)
            .shadow(color: isDisabled ? .clear : HadirTheme.emerald.opacity(0.3), radius: 8, y: 4)
    }
}

struct HadirAlertButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, HadirTheme.spacingXL)
            .padding(.vertical, HadirTheme.spacingMD)
            .background(HadirTheme.terracotta)
            .cornerRadius(HadirTheme.radiusXL)
    }
}

// MARK: - View Extensions

extension View {
    func hadirCard() -> some View {
        self.modifier(HadirCardModifier())
    }
    
    func hadirPrimaryButton(isDisabled: Bool = false) -> some View {
        self.modifier(HadirPrimaryButtonModifier(isDisabled: isDisabled))
    }
    
    func hadirAlertButton() -> some View {
        self.modifier(HadirAlertButtonModifier())
    }
}
