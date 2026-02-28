import SwiftUI

// MARK: - Summary View
// The emotional payoff — "Waktu yang dikembalikan untuk pasienmu hari ini"
// Minute 2:30–3:00 of the 3-minute experience
// "Juri Apple tidak akan lupa angka ini."

struct SummaryView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var appeared = false
    @State private var counterValue: Int = 0
    @State private var showDetails = false
    
    private var timeSavedMinutes: Int {
        coordinator.dailyStats.timeSavedMinutes
    }
    
    var body: some View {
        ZStack {
            HadirTheme.cream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: HadirTheme.spacingXL) {
                    Spacer(minLength: HadirTheme.spacingXL)
                    
                    // Emotional header
                    emotionalHeader
                    
                    // The big number
                    bigNumberSection
                    
                    // Impact message
                    impactMessage
                    
                    // Statistics grid
                    statisticsGrid
                    
                    // Action buttons
                    actionButtons
                    
                    // Closing quote
                    closingQuote
                    
                    Spacer(minLength: HadirTheme.spacingXL)
                }
                .padding(.horizontal, HadirTheme.spacingLG)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
            startCounter()
        }
    }
    
    // MARK: - Emotional Header
    
    private var emotionalHeader: some View {
        VStack(spacing: HadirTheme.spacingMD) {
            Image(systemName: "heart.fill")
                .font(.system(size: 44))
                .foregroundColor(HadirTheme.emerald)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Konsultasi Selesai")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(HadirTheme.textPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Konsultasi selesai")
    }
    
    // MARK: - Big Number — The Hero Stat
    
    private var bigNumberSection: some View {
        VStack(spacing: HadirTheme.spacingSM) {
            Text("Waktu yang dikembalikan\nuntuk pasienmu hari ini:")
                .font(.system(.title3, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            // Animated counter
            Text("\(counterValue)")
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(HadirTheme.emerald)
                .contentTransition(.numericText())
            
            Text("menit")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(HadirTheme.emerald)
        }
        .padding(.vertical, HadirTheme.spacingXL)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: HadirTheme.radiusXL)
                .fill(HadirTheme.emerald.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: HadirTheme.radiusXL)
                        .stroke(HadirTheme.emerald.opacity(0.15), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Waktu yang dikembalikan untuk pasienmu hari ini: \(timeSavedMinutes) menit")
    }
    
    // MARK: - Impact Message
    
    private var impactMessage: some View {
        VStack(spacing: HadirTheme.spacingSM) {
            let extraConsultations = timeSavedMinutes / 12 // avg 12 min per consultation
            
            Text(impactText(minutes: timeSavedMinutes, extraConsultations: extraConsultations))
                .font(.system(.body, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HadirTheme.spacingMD)
        .background(HadirTheme.cardBackground)
        .cornerRadius(HadirTheme.radiusMD)
        .shadow(color: HadirTheme.shadowColor, radius: HadirTheme.shadowRadius, y: HadirTheme.shadowY)
    }
    
    // MARK: - Statistics Grid
    
    private var statisticsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: HadirTheme.spacingMD) {
            StatisticCard(
                icon: "person.2.fill",
                value: "\(coordinator.dailyStats.totalConsultations)",
                label: "Konsultasi\nHari Ini",
                color: HadirTheme.emerald
            )
            
            StatisticCard(
                icon: "stethoscope",
                value: "\(coordinator.dailyStats.symptomsDetected)",
                label: "Gejala\nTerdeteksi",
                color: HadirTheme.doctorColor
            )
            
            StatisticCard(
                icon: "exclamationmark.triangle.fill",
                value: "\(coordinator.dailyStats.redFlagsDetected)",
                label: "Red Flags\nTerdeteksi",
                color: coordinator.dailyStats.redFlagsDetected > 0 ? HadirTheme.terracotta : HadirTheme.textSecondary
            )
            
            StatisticCard(
                icon: "wifi.slash",
                value: "100%",
                label: "Offline\nProcessing",
                color: HadirTheme.emerald
            )
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: HadirTheme.spacingMD) {
            Button(action: {
                coordinator.startNewConsultation()
            }) {
                HStack(spacing: HadirTheme.spacingSM) {
                    Image(systemName: "mic.fill")
                    Text("Konsultasi Berikutnya")
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(HadirTheme.emerald)
                .cornerRadius(HadirTheme.radiusXL)
                .shadow(color: HadirTheme.emerald.opacity(0.3), radius: 12, y: 6)
            }
            .accessibilityLabel("Mulai konsultasi berikutnya")
            
            Button(action: {
                coordinator.backToHome()
            }) {
                Text("Kembali ke Beranda")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundColor(HadirTheme.textSecondary)
            }
            .accessibilityLabel("Kembali ke beranda")
        }
    }
    
    // MARK: - Closing Quote
    
    private var closingQuote: some View {
        VStack(spacing: HadirTheme.spacingSM) {
            Rectangle()
                .fill(HadirTheme.emerald.opacity(0.3))
                .frame(width: 40, height: 2)
            
            Text("\"Dokter yang hadir sepenuhnya\nadalah obat terbaik.\"")
                .font(.system(.callout, design: .rounded))
                .italic()
                .foregroundColor(HadirTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("— Hadir")
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundColor(HadirTheme.emerald)
        }
        .padding(.vertical, HadirTheme.spacingLG)
    }
    
    // MARK: - Helpers
    
    private func startCounter() {
        let target = timeSavedMinutes
        guard target > 0 else {
            counterValue = max(6, timeSavedMinutes) // minimum display
            return
        }
        
        let steps = min(target, 30)
        let interval = 1.0 / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                withAnimation(.easeOut(duration: 0.1)) {
                    counterValue = Int(Double(target) * Double(i) / Double(steps))
                }
            }
        }
    }
    
    private func impactText(minutes: Int, extraConsultations: Int) -> String {
        if minutes >= 30 {
            return "\(minutes) menit. Itu waktu yang cukup untuk \(extraConsultations) konsultasi tambahan. Atau untuk makan siang. Atau untuk sekedar menarik napas."
        } else if minutes >= 10 {
            return "\(minutes) menit yang bisa kamu gunakan untuk benar-benar mendengarkan pasienmu."
        } else {
            return "Setiap menit yang dikembalikan adalah momen koneksi dengan pasienmu."
        }
    }
}
