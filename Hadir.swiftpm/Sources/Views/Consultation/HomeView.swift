import SwiftUI

// MARK: - Home View
// The starting point after onboarding — clean, simple, one clear CTA

struct HomeView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var appeared = false
    @State private var breathe = false
    
    var body: some View {
        ZStack {
            HadirTheme.cream
                .ignoresSafeArea()
            
            VStack(spacing: HadirTheme.spacingXL) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hadir")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(HadirTheme.emerald)
                        
                        Text(greetingText)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(HadirTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Date
                    Text(formattedDate)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HadirTheme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(HadirTheme.cardBackground)
                        .cornerRadius(HadirTheme.radiusSM)
                }
                .padding(.horizontal, HadirTheme.spacingLG)
                .padding(.top, HadirTheme.spacingMD)
                
                Spacer()
                
                // Central CTA
                VStack(spacing: HadirTheme.spacingLG) {
                    // Breathing waveform preview
                    ZStack {
                        Circle()
                            .fill(HadirTheme.emerald.opacity(0.08))
                            .frame(width: 180, height: 180)
                            .scaleEffect(breathe ? 1.1 : 0.95)
                        
                        Circle()
                            .fill(HadirTheme.emerald.opacity(0.12))
                            .frame(width: 130, height: 130)
                            .scaleEffect(breathe ? 1.05 : 0.98)
                        
                        Image(systemName: "waveform.and.mic")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(HadirTheme.emerald)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                            breathe = true
                        }
                    }
                    
                    Button(action: {
                        coordinator.startConsultation()
                    }) {
                        HStack(spacing: HadirTheme.spacingSM) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Mulai Konsultasi")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 300)
                        .padding(.vertical, 18)
                        .background(HadirTheme.emerald)
                        .cornerRadius(HadirTheme.radiusXL)
                        .shadow(color: HadirTheme.emerald.opacity(0.3), radius: 12, y: 6)
                    }
                    .accessibilityLabel("Mulai Konsultasi")
                    .accessibilityHint("Ketuk untuk mulai mendengarkan percakapan dokter-pasien")
                    
                    Text("Tap untuk mulai, Hadir akan mendengarkan")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HadirTheme.textSecondary)
                }
                
                Spacer()
                
                // Today's stats (if any)
                if coordinator.dailyStats.totalConsultations > 0 {
                    todayStatsView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Quote
                Text("\"Karena doktermu seharusnya menatap matamu.\"")
                    .font(.system(.caption, design: .rounded))
                    .italic()
                    .foregroundColor(HadirTheme.textSecondary.opacity(0.7))
                    .padding(.bottom, HadirTheme.spacingLG)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Today's Stats
    
    private var todayStatsView: some View {
        HStack(spacing: HadirTheme.spacingMD) {
            miniStat(
                icon: "person.2.fill",
                value: "\(coordinator.dailyStats.totalConsultations)",
                label: "Konsultasi"
            )
            
            miniStat(
                icon: "clock.arrow.circlepath",
                value: "\(coordinator.dailyStats.timeSavedMinutes) min",
                label: "Waktu disimpan"
            )
            
            if coordinator.dailyStats.redFlagsDetected > 0 {
                miniStat(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(coordinator.dailyStats.redFlagsDetected)",
                    label: "Red Flag"
                )
            }
        }
        .padding(.horizontal, HadirTheme.spacingLG)
        .padding(.bottom, HadirTheme.spacingMD)
    }
    
    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(HadirTheme.emerald)
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(HadirTheme.textPrimary)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HadirTheme.spacingMD)
        .background(HadirTheme.cardBackground)
        .cornerRadius(HadirTheme.radiusMD)
        .shadow(color: HadirTheme.shadowColor, radius: 4, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
    
    // MARK: - Helpers
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Selamat pagi, Dok 🌅"
        case 12..<17: return "Selamat siang, Dok ☀️"
        case 17..<21: return "Selamat sore, Dok 🌇"
        default: return "Selamat malam, Dok 🌙"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: Date())
    }
}
