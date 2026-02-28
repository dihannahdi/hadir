import SwiftUI
import UIKit

// MARK: - Consultation View
// The main listening screen — breathing waveform + real-time transcript + SOAP assembly
// This is the "magic moment" (Minute 0:30–2:00 of the 3-minute experience)

struct ConsultationView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var showSOAPPanel = true
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            HadirTheme.cream
                .ignoresSafeArea()
            
            if horizontalSizeClass == .regular {
                // iPad: side-by-side layout
                iPadLayout
            } else {
                // iPhone: stacked layout with toggle
                iPhoneLayout
            }
            
            // Red Flag Alert Overlay
            if coordinator.showRedFlagAlert, let redFlag = coordinator.currentRedFlag {
                RedFlagAlertView(redFlag: redFlag) {
                    coordinator.dismissRedFlagAlert()
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }
    
    // MARK: - iPad Layout (Split View)
    
    private var iPadLayout: some View {
        HStack(spacing: 0) {
            // Left: Waveform + Transcript
            VStack(spacing: HadirTheme.spacingMD) {
                headerBar
                micDeniedBanner
                waveformSection
                transcriptSection
            }
            .frame(maxWidth: .infinity)
            .padding(HadirTheme.spacingMD)
            
            // Divider
            Rectangle()
                .fill(HadirTheme.border)
                .frame(width: 1)
            
            // Right: SOAP Note Assembly
            VStack(spacing: HadirTheme.spacingMD) {
                soapHeaderBar
                soapAssemblySection
                endButton
            }
            .frame(maxWidth: .infinity)
            .padding(HadirTheme.spacingMD)
        }
    }
    
    // MARK: - iPhone Layout
    
    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            headerBar
                .padding(.horizontal, HadirTheme.spacingMD)
                .padding(.top, HadirTheme.spacingSM)
            
            micDeniedBanner
                .padding(.top, HadirTheme.spacingXS)
            
            // Toggle between transcript and SOAP
            Picker("Tampilan", selection: $showSOAPPanel) {
                Text("Transkrip").tag(false)
                Text("SOAP Note").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, HadirTheme.spacingMD)
            .padding(.vertical, HadirTheme.spacingSM)
            
            if showSOAPPanel {
                soapAssemblySection
                    .transition(.move(edge: .trailing))
            } else {
                VStack(spacing: HadirTheme.spacingMD) {
                    waveformSection
                    transcriptSection
                }
                .transition(.move(edge: .leading))
            }
            
            endButton
                .padding(.horizontal, HadirTheme.spacingMD)
                .padding(.bottom, HadirTheme.spacingMD)
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Recording / Demo indicator
            HStack(spacing: HadirTheme.spacingSM) {
                if coordinator.speechService.isInDemoMode {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.orange)
                    Text("MODE DEMO")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(.orange)
                } else {
                    PulsingDot(color: .red)
                    Text("MEREKAM")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background((coordinator.speechService.isInDemoMode ? Color.orange : Color.red).opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            // Timer
            Text(coordinator.formattedElapsedTime)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(HadirTheme.textPrimary)
            
            Spacer()
            
            // Symptoms count badge
            if !coordinator.soapGenerator.allDetectedSymptoms.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 12))
                    Text("\(coordinator.soapGenerator.allDetectedSymptoms.count)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                }
                .foregroundColor(HadirTheme.emerald)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(HadirTheme.emeraldLight)
                .cornerRadius(10)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sedang merekam. Durasi \(coordinator.formattedElapsedTime). \(coordinator.soapGenerator.allDetectedSymptoms.count) gejala terdeteksi.")
    }
    
    // MARK: - SOAP Header (iPad right panel)
    
    private var soapHeaderBar: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(HadirTheme.emerald)
            Text("SOAP Note")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(HadirTheme.textPrimary)
            Spacer()
            
            if coordinator.soapGenerator.isProcessing {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    // MARK: - Mic Denied Banner
    
    @ViewBuilder
    private var micDeniedBanner: some View {
        if coordinator.speechService.isMicDenied {
            HStack(spacing: HadirTheme.spacingSM) {
                Image(systemName: "mic.slash.fill")
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Akses Mikrofon Ditolak")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    Text("Izinkan Hadir di Pengaturan\u00A0\u203A\u00A0Privasi\u00A0\u203A\u00A0Mikrofon")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                Spacer()
                Button("Pengaturan") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.25))
                .cornerRadius(8)
            }
            .padding(HadirTheme.spacingMD)
            .background(HadirTheme.terracotta)
            .cornerRadius(12)
            .padding(.horizontal, HadirTheme.spacingMD)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    // MARK: - Waveform Section
    
    private var waveformSection: some View {
        BreathingWaveformView(
            audioLevel: coordinator.speechService.audioLevel,
            isListening: coordinator.speechService.isListening
        )
        .frame(height: horizontalSizeClass == .regular ? 200 : 150)
    }
    
    // MARK: - Transcript Section
    
    private var transcriptSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: HadirTheme.spacingMD) {
                    ForEach(coordinator.soapGenerator.currentNote.transcript) { entry in
                        transcriptEntryView(entry)
                            .id(entry.id)
                    }
                    
                    // Current partial transcript
                    if !coordinator.speechService.currentTranscript.isEmpty {
                        currentTranscriptView
                    }
                }
                .padding(HadirTheme.spacingMD)
            }
            .background(HadirTheme.cardBackground)
            .cornerRadius(HadirTheme.radiusMD)
            .onChange(of: coordinator.soapGenerator.currentNote.transcript.count) { _, _ in
                if let lastId = coordinator.soapGenerator.currentNote.transcript.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func transcriptEntryView(_ entry: TranscriptEntry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Speaker label
            HStack(spacing: 4) {
                Image(systemName: entry.speaker == .doctor ? "stethoscope" : "person.fill")
                    .font(.system(size: 10))
                Text(entry.speaker.rawValue)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                
                Spacer()
                
                Text(formatTimestamp(entry.timestamp))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(HadirTheme.textSecondary)
            }
            .foregroundColor(entry.speaker == .doctor ? HadirTheme.doctorColor : HadirTheme.patientColor)
            
            // Text with highlights
            AnimatedTranscriptText(
                text: entry.text,
                highlightedTerms: entry.highlightedTerms,
                speaker: entry.speaker
            )
        }
        .padding(HadirTheme.spacingSM)
        .background(
            (entry.speaker == .doctor ? HadirTheme.doctorColor : HadirTheme.patientColor)
                .opacity(0.04)
        )
        .cornerRadius(HadirTheme.radiusSM)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.speaker.rawValue): \(entry.text)")
    }
    
    private var currentTranscriptView: some View {
        HStack(alignment: .top, spacing: HadirTheme.spacingSM) {
            PulsingDot(color: HadirTheme.emerald)
                .padding(.top, 4)
            
            Text(coordinator.speechService.currentTranscript)
                .font(.system(.body, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
                .italic()
        }
        .padding(HadirTheme.spacingSM)
        .accessibilityLabel("Sedang mendengarkan: \(coordinator.speechService.currentTranscript)")
    }
    
    // MARK: - SOAP Assembly Section
    
    private var soapAssemblySection: some View {
        ScrollView {
            VStack(spacing: HadirTheme.spacingMD) {
                let note = coordinator.soapGenerator.currentNote
                
                SOAPAssemblyView(
                    label: "S — Subjective",
                    content: note.subjective.summary,
                    color: HadirTheme.patientColor,
                    icon: "person.wave.2.fill",
                    isVisible: true,
                    delay: 0
                )
                
                SOAPAssemblyView(
                    label: "O — Objective",
                    content: note.objective.summary,
                    color: HadirTheme.doctorColor,
                    icon: "stethoscope",
                    isVisible: true,
                    delay: 0.1
                )
                
                SOAPAssemblyView(
                    label: "A — Assessment",
                    content: note.assessment.summary,
                    color: HadirTheme.emerald,
                    icon: "brain.head.profile",
                    isVisible: true,
                    delay: 0.2
                )
                
                SOAPAssemblyView(
                    label: "P — Plan",
                    content: note.plan.summary,
                    color: .purple,
                    icon: "list.clipboard.fill",
                    isVisible: true,
                    delay: 0.3
                )
                
                // Detected symptoms chips
                if !coordinator.soapGenerator.allDetectedSymptoms.isEmpty {
                    detectedSymptomsView
                }
                
                // Red flags
                if !coordinator.soapGenerator.detectedRedFlags.isEmpty {
                    redFlagsView
                }
            }
            .padding(HadirTheme.spacingMD)
        }
    }
    
    // MARK: - Detected Symptoms
    
    private var detectedSymptomsView: some View {
        VStack(alignment: .leading, spacing: HadirTheme.spacingSM) {
            Text("Gejala Terdeteksi")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundColor(HadirTheme.textSecondary)
            
            FlowLayout(spacing: 6) {
                ForEach(coordinator.soapGenerator.allDetectedSymptoms) { symptom in
                    Text(symptom.indonesianName)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(HadirTheme.emerald)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(HadirTheme.emeraldLight)
                        .cornerRadius(12)
                }
            }
        }
        .padding(HadirTheme.spacingMD)
        .background(HadirTheme.cardBackground)
        .cornerRadius(HadirTheme.radiusMD)
    }
    
    // MARK: - Red Flags Section
    
    private var redFlagsView: some View {
        VStack(alignment: .leading, spacing: HadirTheme.spacingSM) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(HadirTheme.terracotta)
                Text("Red Flags")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(HadirTheme.terracotta)
            }
            
            ForEach(coordinator.soapGenerator.detectedRedFlags) { flag in
                HStack {
                    Circle()
                        .fill(HadirTheme.terracotta)
                        .frame(width: 8, height: 8)
                    Text(flag.condition)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(HadirTheme.textPrimary)
                }
            }
        }
        .padding(HadirTheme.spacingMD)
        .background(HadirTheme.terracottaLight)
        .cornerRadius(HadirTheme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: HadirTheme.radiusMD)
                .stroke(HadirTheme.terracotta.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Red Flags terdeteksi: \(coordinator.soapGenerator.detectedRedFlags.map { $0.condition }.joined(separator: ", "))")
    }
    
    // MARK: - End Button
    
    private var endButton: some View {
        Button(action: {
            coordinator.endConsultation()
        }) {
            HStack(spacing: HadirTheme.spacingSM) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 20))
                Text("Selesai Konsultasi")
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(HadirTheme.terracotta)
            .cornerRadius(HadirTheme.radiusXL)
        }
        .accessibilityLabel("Selesai Konsultasi")
        .accessibilityHint("Ketuk untuk mengakhiri konsultasi dan melihat SOAP note")
    }
    
    // MARK: - Helpers
    
    private func formatTimestamp(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
