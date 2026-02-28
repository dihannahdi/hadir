import SwiftUI

// MARK: - Onboarding View
// Emotional, zero-friction onboarding — designed for the first 30 seconds
// "Sudah berapa lama doktermu tidak menatap matamu?"

struct OnboardingView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var currentPage = 0
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateButton = false
    @State private var showSilhouette = false
    @State private var hideScreen = false
    
    var body: some View {
        ZStack {
            // Background
            HadirTheme.cream
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: The emotional hook
                emotionalHookPage
                    .tag(0)
                
                // Page 2: The problem
                problemPage
                    .tag(1)
                
                // Page 3: The solution — CTA
                solutionPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .accessibilityAction(.escape) {
            coordinator.completeOnboarding()
        }
    }
    
    // MARK: - Page 1: Emotional Hook
    
    private var emotionalHookPage: some View {
        VStack(spacing: HadirTheme.spacingXL) {
            Spacer()
            
            // Silhouette animation — doctor and patient
            ZStack {
                // Patient silhouette
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(HadirTheme.emerald.opacity(0.4))
                    .offset(x: -40, y: showSilhouette ? 0 : 30)
                    .opacity(showSilhouette ? 1 : 0)
                
                // Doctor silhouette
                Image(systemName: "stethoscope")
                    .font(.system(size: 50))
                    .foregroundColor(HadirTheme.emerald)
                    .offset(x: 40, y: showSilhouette ? 0 : 30)
                    .opacity(showSilhouette ? 1 : 0)
                
                // Screen between them (fading away)
                Image(systemName: "laptopcomputer")
                    .font(.system(size: 30))
                    .foregroundColor(HadirTheme.textSecondary.opacity(0.5))
                    .opacity(showSilhouette ? 0 : 0.8)
                    .scaleEffect(showSilhouette ? 0.5 : 1.0)
            }
            .frame(height: 120)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                    showSilhouette = true
                }
            }
            
            VStack(spacing: HadirTheme.spacingMD) {
                Text("Sudah berapa lama")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundColor(HadirTheme.textSecondary)
                    .opacity(animateTitle ? 1 : 0)
                    .offset(y: animateTitle ? 0 : 15)
                
                Text("doktermu tidak\nmenatap matamu?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(HadirTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(animateSubtitle ? 1 : 0)
                    .offset(y: animateSubtitle ? 0 : 15)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
                    animateTitle = true
                }
                withAnimation(.easeOut(duration: 0.8).delay(1.3)) {
                    animateSubtitle = true
                }
            }
            
            Spacer()
            
            // Swipe hint
            VStack(spacing: HadirTheme.spacingSM) {
                Image(systemName: "chevron.right.2")
                    .font(.system(size: 20))
                    .foregroundColor(HadirTheme.textSecondary.opacity(0.5))
                Text("Geser untuk melanjutkan")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(HadirTheme.textSecondary.opacity(0.5))
            }
            .padding(.bottom, HadirTheme.spacingXL)
        }
        .padding(.horizontal, HadirTheme.spacingXL)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sudah berapa lama doktermu tidak menatap matamu? Geser untuk melanjutkan.")
    }
    
    // MARK: - Page 2: The Problem
    
    private var problemPage: some View {
        VStack(spacing: HadirTheme.spacingXL) {
            Spacer()
            
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(HadirTheme.terracotta)
                .symbolEffect(.pulse, options: .repeating)
            
            VStack(spacing: HadirTheme.spacingMD) {
                Text("40%")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(HadirTheme.terracotta)
                
                Text("waktu konsultasi dihabiskan\nuntuk mengetik, bukan merawat")
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(HadirTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            // Stats
            VStack(spacing: HadirTheme.spacingMD) {
                statRow(icon: "building.2", text: "15.000 Puskesmas di Indonesia")
                statRow(icon: "person.3.fill", text: "270 juta jiwa dilayani")
                statRow(icon: "person.crop.circle.badge.clock", text: "40-80 pasien per hari per dokter")
            }
            .padding(HadirTheme.spacingLG)
            .background(HadirTheme.cardBackground)
            .cornerRadius(HadirTheme.radiusLG)
            .shadow(color: HadirTheme.shadowColor, radius: HadirTheme.shadowRadius, y: HadirTheme.shadowY)
            
            Spacer()
        }
        .padding(.horizontal, HadirTheme.spacingXL)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("40 persen waktu konsultasi dihabiskan untuk mengetik, bukan merawat. 15 ribu Puskesmas di Indonesia melayani 270 juta jiwa.")
    }
    
    // MARK: - Page 3: The Solution
    
    private var solutionPage: some View {
        VStack(spacing: HadirTheme.spacingXL) {
            Spacer()
            
            // App logo / name
            VStack(spacing: HadirTheme.spacingMD) {
                Image(systemName: "waveform.and.mic")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(HadirTheme.emerald)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                
                Text("Hadir")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(HadirTheme.emerald)
                
                Text("AI Clinical Companion")
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(HadirTheme.textSecondary)
            }
            
            // What it does
            VStack(spacing: HadirTheme.spacingMD) {
                featureRow(icon: "ear.fill", text: "Mendengarkan percakapan dokter-pasien")
                featureRow(icon: "text.viewfinder", text: "Transkripsi real-time, kata per kata")
                featureRow(icon: "doc.text.fill", text: "SOAP note otomatis, siap simpan")
                featureRow(icon: "wifi.slash", text: "100% offline — tanpa internet")
            }
            .padding(HadirTheme.spacingLG)
            .background(HadirTheme.cardBackground)
            .cornerRadius(HadirTheme.radiusLG)
            .shadow(color: HadirTheme.shadowColor, radius: HadirTheme.shadowRadius, y: HadirTheme.shadowY)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                coordinator.completeOnboarding()
            }) {
                HStack(spacing: HadirTheme.spacingSM) {
                    Text("Mulai Konsultasi")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(HadirTheme.emerald)
                .cornerRadius(HadirTheme.radiusXL)
                .shadow(color: HadirTheme.emerald.opacity(0.3), radius: 12, y: 6)
            }
            .scaleEffect(animateButton ? 1.0 : 0.9)
            .opacity(animateButton ? 1.0 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                    animateButton = true
                }
            }
            .accessibilityLabel("Mulai Konsultasi")
            .accessibilityHint("Ketuk untuk memulai menggunakan Hadir")
            
            Text("Karena doktermu seharusnya menatap matamu,\nbukan layar komputernya.")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, HadirTheme.spacingLG)
        }
        .padding(.horizontal, HadirTheme.spacingXL)
    }
    
    // MARK: - Helpers
    
    private func statRow(icon: String, text: String) -> some View {
        HStack(spacing: HadirTheme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(HadirTheme.terracotta)
                .frame(width: 32)
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(HadirTheme.textPrimary)
            
            Spacer()
        }
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: HadirTheme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(HadirTheme.emerald)
                .frame(width: 32)
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(HadirTheme.textPrimary)
            
            Spacer()
        }
    }
}
