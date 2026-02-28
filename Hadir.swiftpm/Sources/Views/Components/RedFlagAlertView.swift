import SwiftUI

// MARK: - Red Flag Alert View
// Full-screen overlay when a critical/high red flag is detected
// Uses terracotta color with strong haptic feedback

struct RedFlagAlertView: View {
    let redFlag: RedFlag
    let onDismiss: () -> Void
    
    @State private var appeared = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            // Alert card
            VStack(spacing: HadirTheme.spacingLG) {
                // Urgency indicator
                ZStack {
                    Circle()
                        .fill(urgencyColor.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                    
                    Circle()
                        .fill(urgencyColor.opacity(0.4))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Title
                Text("⚠️ RED FLAG")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(urgencyColor)
                
                Text(redFlag.condition)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(HadirTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                // Urgency badge
                Text(redFlag.urgencyLevel.rawValue.uppercased())
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(urgencyColor)
                    .cornerRadius(12)
                
                // Detected symptoms
                VStack(alignment: .leading, spacing: HadirTheme.spacingSM) {
                    Text("Gejala Terdeteksi:")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(HadirTheme.textSecondary)
                    
                    ForEach(redFlag.symptoms, id: \.self) { symptom in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(urgencyColor)
                            Text(symptom.capitalized)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(HadirTheme.textPrimary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HadirTheme.spacingMD)
                .background(urgencyColor.opacity(0.08))
                .cornerRadius(HadirTheme.radiusSM)
                
                // Action recommendation
                VStack(alignment: .leading, spacing: HadirTheme.spacingSM) {
                    Text("Rekomendasi Tindakan:")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(HadirTheme.textSecondary)
                    
                    Text(redFlag.action)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundColor(HadirTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HadirTheme.spacingMD)
                .background(HadirTheme.emerald.opacity(0.08))
                .cornerRadius(HadirTheme.radiusSM)
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text("Dipahami")
                        .hadirAlertButton()
                }
            }
            .padding(HadirTheme.spacingXL)
            .background(HadirTheme.cream)
            .cornerRadius(HadirTheme.radiusXL)
            .shadow(color: urgencyColor.opacity(0.3), radius: 20)
            .padding(HadirTheme.spacingLG)
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Peringatan Red Flag: \(redFlag.condition). Urgensi: \(redFlag.urgencyLevel.rawValue). \(redFlag.action)")
        .accessibilityAddTraits(.isModal)
    }
    
    private var urgencyColor: Color {
        switch redFlag.urgencyLevel {
        case .critical: return Color.red
        case .high: return HadirTheme.terracotta
        case .moderate: return .orange
        }
    }
}
