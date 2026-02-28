import Foundation
import CoreHaptics
import UIKit

// MARK: - Haptic Feedback Service
// Uses Core Haptics for Red Flag alerts and interaction feedback
// Doctors can "feel" urgency without looking at the screen

@MainActor
class HapticService {
    
    // MARK: - Singleton
    
    static let shared = HapticService()
    
    // MARK: - Properties
    
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool
    
    // MARK: - Initialization
    
    private init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepareEngine()
    }
    
    // MARK: - Engine Setup
    
    private func prepareEngine() {
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            engine?.stoppedHandler = { [weak self] reason in
                Task { @MainActor in
                    self?.prepareEngine()
                }
            }
            engine?.resetHandler = { [weak self] in
                Task { @MainActor in
                    try? self?.engine?.start()
                }
            }
            try engine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }
    
    // MARK: - Red Flag Alert — Critical (Strongest)
    
    /// Distinctive haptic pattern for critical red flags (e.g., ACS, Stroke)
    /// Three strong pulses followed by continuous vibration — unmistakable urgency
    func playRedFlagCritical() {
        guard supportsHaptics, let engine = engine else {
            // Fallback to UIKit haptics
            playFallbackHaptic(style: .heavy, count: 3)
            return
        }
        
        do {
            var events: [CHHapticEvent] = []
            
            // Three strong impact pulses
            for i in 0..<3 {
                let time = Double(i) * 0.2
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: time
                ))
            }
            
            // Continuous buzz after the pulses
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.7,
                duration: 0.8
            ))
            
            // Final strong pulse
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 1.6
            ))
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play critical haptic: \(error)")
            playFallbackHaptic(style: .heavy, count: 3)
        }
    }
    
    // MARK: - Red Flag Alert — High
    
    /// Two firm pulses for high-urgency flags
    func playRedFlagHigh() {
        guard supportsHaptics, let engine = engine else {
            playFallbackHaptic(style: .medium, count: 2)
            return
        }
        
        do {
            var events: [CHHapticEvent] = []
            
            for i in 0..<2 {
                let time = Double(i) * 0.25
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                    ],
                    relativeTime: time
                ))
            }
            
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.6,
                duration: 0.5
            ))
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            playFallbackHaptic(style: .medium, count: 2)
        }
    }
    
    // MARK: - Symptom Detected — Subtle Confirmation
    
    /// Light tap when a medical keyword is detected
    func playSymptomDetected() {
        guard supportsHaptics, let engine = engine else {
            playFallbackHaptic(style: .light, count: 1)
            return
        }
        
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            playFallbackHaptic(style: .light, count: 1)
        }
    }
    
    // MARK: - SOAP Note Saved — Satisfying Click
    
    /// The signature "stamp click" when a SOAP note is saved
    func playNoteSaved() {
        guard supportsHaptics, let engine = engine else {
            playFallbackHaptic(style: .medium, count: 1)
            return
        }
        
        do {
            var events: [CHHapticEvent] = []
            
            // Quick sharp tap (like a stamp)
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: 0
            ))
            
            // Soft follow-up (satisfying finish)
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.1
            ))
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            playFallbackHaptic(style: .medium, count: 1)
        }
    }
    
    // MARK: - Start Listening — Gentle Pulse
    
    func playStartListening() {
        guard supportsHaptics, let engine = engine else {
            playFallbackHaptic(style: .soft, count: 1)
            return
        }
        
        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
                ],
                relativeTime: 0,
                duration: 0.3
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            playFallbackHaptic(style: .soft, count: 1)
        }
    }
    
    // MARK: - Fallback Haptics (UIKit)
    
    private func playFallbackHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle, count: Int) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                generator.impactOccurred()
            }
        }
    }
}


