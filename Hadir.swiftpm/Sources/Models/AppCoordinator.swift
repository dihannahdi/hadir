import SwiftUI
import Combine

// MARK: - App Coordinator
// Manages app navigation state and consultation flow

@MainActor
class AppCoordinator: ObservableObject {
    
    // MARK: - Navigation State
    
    enum AppScreen: Equatable {
        case onboarding
        case home
        case consultation
        case soapReview
        case summary
    }
    
    @Published var currentScreen: AppScreen = .onboarding
    @Published var hasCompletedOnboarding: Bool = false
    @Published var showRedFlagAlert: Bool = false
    @Published var currentRedFlag: RedFlag?
    
    // MARK: - Services
    
    let speechService = SpeechTranscriptionService()
    let soapGenerator = SOAPNoteGenerator()
    
    // MARK: - Session Data
    
    @Published var currentSession: ConsultationSession?
    @Published var completedSessions: [ConsultationSession] = []
    @Published var dailyStats = DailyStatistics()
    
    // MARK: - Timer
    
    @Published var elapsedTime: TimeInterval = 0
    private var timer: Timer?
    private var lastKnownRedFlagCount = 0
    
    // MARK: - Combine
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        // Check if onboarding was completed
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if hasCompletedOnboarding {
            currentScreen = .home
        }
        loadDailyStats()
        
        // Forward nested ObservableObject changes to trigger SwiftUI updates
        speechService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        soapGenerator.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation
    
    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            currentScreen = .home
        }
    }
    
    func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
    
    // MARK: - Consultation Flow
    
    func startConsultation() {
        currentSession = ConsultationSession()
        soapGenerator.reset()
        speechService.reset()
        elapsedTime = 0
        lastKnownRedFlagCount = 0
        
        do {
            try speechService.startListening()
            HapticService.shared.playStartListening()
            startTimer()
            navigateTo(.consultation)
        } catch {
            print("Failed to start consultation: \(error)")
        }
    }
    
    func endConsultation() {
        speechService.stopListening()
        stopTimer()
        
        if var session = currentSession {
            session.endTime = Date()
            session.status = .completed
            session.soapNote = soapGenerator.finalizeNote(duration: elapsedTime)
            currentSession = session
        }
        
        navigateTo(.soapReview)
    }
    
    func saveAndFinish() {
        HapticService.shared.playNoteSaved()
        
        if let session = currentSession {
            completedSessions.append(session)
            updateDailyStats(with: session)
        }
        
        navigateTo(.summary)
    }
    
    func startNewConsultation() {
        navigateTo(.home)
    }
    
    func backToHome() {
        navigateTo(.home)
    }
    
    // MARK: - Red Flag Handling
    
    func triggerRedFlagAlert(_ redFlag: RedFlag) {
        currentRedFlag = redFlag
        showRedFlagAlert = true
        
        switch redFlag.urgencyLevel {
        case .critical:
            HapticService.shared.playRedFlagCritical()
        case .high:
            HapticService.shared.playRedFlagHigh()
        case .moderate:
            HapticService.shared.playSymptomDetected()
        }
    }
    
    func dismissRedFlagAlert() {
        showRedFlagAlert = false
        currentRedFlag = nil
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime += 1
                self?.processLatestTranscript()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Real-time Processing
    
    private func processLatestTranscript() {
        let entries = speechService.transcriptEntries
        soapGenerator.processTranscriptEntries(entries)
        
        // Check for new red flags
        if soapGenerator.detectedRedFlags.count > lastKnownRedFlagCount,
           let newFlag = soapGenerator.detectedRedFlags.last {
            triggerRedFlagAlert(newFlag)
        }
        lastKnownRedFlagCount = soapGenerator.detectedRedFlags.count
    }
    
    // MARK: - Statistics
    
    private func updateDailyStats(with session: ConsultationSession) {
        dailyStats.totalConsultations += 1
        dailyStats.totalTimeSaved += session.soapNote.estimatedTimeSaved
        dailyStats.redFlagsDetected += session.soapNote.redFlagsTriggered.count
        dailyStats.symptomsDetected += session.soapNote.detectedSymptoms.count
        saveDailyStats()
    }
    
    private func saveDailyStats() {
        if let data = try? JSONEncoder().encode(dailyStats) {
            UserDefaults.standard.set(data, forKey: "dailyStats_\(dateKey)")
        }
    }
    
    private func loadDailyStats() {
        if let data = UserDefaults.standard.data(forKey: "dailyStats_\(dateKey)"),
           let stats = try? JSONDecoder().decode(DailyStatistics.self, from: data) {
            dailyStats = stats
        }
    }
    
    private var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    // MARK: - Formatted Time
    
    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
