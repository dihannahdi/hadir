import SwiftUI

// MARK: - Breathing Waveform Animation
// Signature visual — circles that pulse like breathing, showing the app is listening
// "Like a doctor breathing together with their patient"

struct BreathingWaveformView: View {
    let audioLevel: Float
    let isListening: Bool
    
    @State private var breathePhase: CGFloat = 0
    @State private var wavePhases: [CGFloat] = Array(repeating: 0, count: 5)
    
    private let circleCount = 5
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            HadirTheme.emerald.opacity(0.15),
                            HadirTheme.emerald.opacity(0.0)
                        ]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .scaleEffect(isListening ? 1.0 + breathePhase * 0.1 : 0.8)
            
            // Concentric breathing circles
            ForEach(0..<circleCount, id: \.self) { i in
                BreathingCircle(
                    index: i,
                    totalCircles: circleCount,
                    audioLevel: audioLevel,
                    breathePhase: breathePhase,
                    isListening: isListening
                )
            }
            
            // Center microphone icon
            Image(systemName: isListening ? "mic.fill" : "mic")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(isListening ? HadirTheme.emerald : HadirTheme.textSecondary)
                .scaleEffect(isListening ? 1.0 + breathePhase * 0.15 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isListening)
        }
        .onAppear {
            startBreathing()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isListening ? "Sedang mendengarkan percakapan" : "Mikrofon tidak aktif")
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true)
        ) {
            breathePhase = 1.0
        }
    }
}

// MARK: - Individual Breathing Circle

struct BreathingCircle: View {
    let index: Int
    let totalCircles: Int
    let audioLevel: Float
    let breathePhase: CGFloat
    let isListening: Bool
    
    @State private var animatedScale: CGFloat = 1.0
    
    private var baseSize: CGFloat {
        let step: CGFloat = 40
        return CGFloat(index + 1) * step + 20
    }
    
    private var delay: Double {
        Double(index) * 0.15
    }
    
    private var audioInfluence: CGFloat {
        let level = CGFloat(min(audioLevel * 8, 1.0))
        return level * CGFloat(index + 1) * 0.03
    }
    
    var body: some View {
        Circle()
            .stroke(
                HadirTheme.emerald.opacity(opacity),
                lineWidth: lineWidth
            )
            .frame(width: baseSize, height: baseSize)
            .scaleEffect(scale)
            .animation(
                .easeInOut(duration: 2.5 + Double(index) * 0.3)
                .repeatForever(autoreverses: true)
                .delay(delay),
                value: breathePhase
            )
            .animation(.easeOut(duration: 0.1), value: audioLevel)
    }
    
    private var scale: CGFloat {
        if !isListening { return 0.85 }
        return 1.0 + breathePhase * 0.08 * CGFloat(totalCircles - index) / CGFloat(totalCircles) + audioInfluence
    }
    
    private var opacity: Double {
        if !isListening { return 0.15 }
        let base = 0.6 - Double(index) * 0.08
        let audioBoost = Double(audioLevel) * 0.3
        return min(base + audioBoost, 0.8)
    }
    
    private var lineWidth: CGFloat {
        let base: CGFloat = 3.0 - CGFloat(index) * 0.3
        let audioBoost = CGFloat(audioLevel) * 4.0
        return max(base + audioBoost, 1.0)
    }
}

// MARK: - SOAP Assembly Animation

struct SOAPAssemblyView: View {
    let label: String
    let content: String
    let color: Color
    let icon: String
    let isVisible: Bool
    let delay: Double
    
    @State private var appeared = false
    
    var body: some View {
        if !content.isEmpty || isVisible {
            VStack(alignment: .leading, spacing: HadirTheme.spacingSM) {
                // Header
                HStack(spacing: HadirTheme.spacingSM) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                    
                    Text(label)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(color)
                    
                    Spacer()
                }
                
                // Content
                if !content.isEmpty {
                    Text(content)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(HadirTheme.textPrimary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HadirTheme.spacingMD)
            .background(color.opacity(0.06))
            .cornerRadius(HadirTheme.radiusMD)
            .overlay(
                RoundedRectangle(cornerRadius: HadirTheme.radiusMD)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .offset(y: appeared ? 0 : 20)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                    appeared = true
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(label): \(content.isEmpty ? "Belum terisi" : content)")
        }
    }
}

// MARK: - Word-by-Word Text View

struct AnimatedTranscriptText: View {
    let text: String
    let highlightedTerms: [HighlightedTerm]
    let speaker: TranscriptEntry.Speaker
    
    var body: some View {
        let words = text.components(separatedBy: " ")
        
        FlowLayout(spacing: 4) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text(word)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(colorForWord(word))
                    .padding(.horizontal, isHighlighted(word) ? 4 : 0)
                    .padding(.vertical, isHighlighted(word) ? 2 : 0)
                    .background(
                        isHighlighted(word) ?
                        categoryColor(for: word).opacity(0.15) :
                        Color.clear
                    )
                    .cornerRadius(4)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
    }
    
    private func isHighlighted(_ word: String) -> Bool {
        let lowered = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
        return highlightedTerms.contains { $0.term.lowercased().contains(lowered) && lowered.count > 2 }
    }
    
    private func colorForWord(_ word: String) -> Color {
        if isHighlighted(word) {
            return categoryColor(for: word)
        }
        return speaker == .doctor ? HadirTheme.doctorColor : HadirTheme.patientColor
    }
    
    private func categoryColor(for word: String) -> Color {
        let lowered = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
        let term = highlightedTerms.first { $0.term.lowercased().contains(lowered) }
        switch term?.category {
        case .symptom: return HadirTheme.emerald
        case .medication: return .blue
        case .duration: return .purple
        case .bodyPart: return .orange
        case .redFlag: return HadirTheme.terracotta
        case .vitalSign: return .teal
        case .none: return HadirTheme.textPrimary
        }
    }
}

// MARK: - Flow Layout (for word wrapping)

struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 300, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            guard index < subviews.count else { break }
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }
    
    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            positions.append(CGPoint(x: x, y: y))
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
        }
        
        return (CGSize(width: maxWidth, height: y + maxHeight), positions)
    }
}

// MARK: - Pulsing Dot Indicator

struct PulsingDot: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .scaleEffect(isPulsing ? 1.3 : 0.8)
            .opacity(isPulsing ? 1.0 : 0.5)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Statistic Card

struct StatisticCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: HadirTheme.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(HadirTheme.textPrimary)
            
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(HadirTheme.spacingMD)
        .background(HadirTheme.cardBackground)
        .cornerRadius(HadirTheme.radiusMD)
        .shadow(color: HadirTheme.shadowColor, radius: HadirTheme.shadowRadius, y: HadirTheme.shadowY)
        .scaleEffect(appeared ? 1.0 : 0.8)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
