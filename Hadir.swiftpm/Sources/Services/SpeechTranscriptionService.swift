import Foundation
import Speech
import AVFoundation

// MARK: - Speech Transcription Service
// Real-time on-device speech recognition using Apple's Speech Framework
// Supports Bahasa Indonesia (id-ID) — works 100% offline on iOS 17+

@MainActor
class SpeechTranscriptionService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isListening = false
    @Published var currentTranscript = ""
    @Published var transcriptEntries: [TranscriptEntry] = []
    @Published var audioLevel: Float = 0.0
    @Published var error: SpeechError?
    @Published var isAuthorized = false
    
    // MARK: - Private Properties
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var startTime: Date?
    private var lastSpeaker: TranscriptEntry.Speaker = .unknown
    private var silenceTimer: Timer?
    private var currentSegmentText = ""
    private var lastTranscriptLength = 0
    
    // MARK: - Configuration
    
    /// Language for recognition — Bahasa Indonesia
    private let locale = Locale(identifier: "id-ID")
    
    /// Minimum silence duration to consider speaker change (seconds)
    private let silenceThreshold: TimeInterval = 2.0
    
    // MARK: - Initialization
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func checkAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self?.isAuthorized = false
                    self?.error = .notAuthorized
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
    }
    
    // MARK: - Start Listening
    
    func startListening() throws {
        // Cancel any existing task
        stopListening()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerNotAvailable
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }
        
        // Configure for real-time results
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = true // Force on-device — critical for offline-first
        
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = true
        }
        
        startTime = Date()
        lastTranscriptLength = 0
        currentSegmentText = ""
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let result = result {
                    let fullText = result.bestTranscription.formattedString
                    self.currentTranscript = fullText
                    
                    // Detect new words added
                    if fullText.count > self.lastTranscriptLength {
                        let newText = String(fullText.suffix(fullText.count - self.lastTranscriptLength))
                        self.currentSegmentText += newText
                        self.lastTranscriptLength = fullText.count
                        
                        // Reset silence timer
                        self.resetSilenceTimer()
                    }
                    
                    if result.isFinal {
                        self.finalizeCurrentSegment()
                    }
                }
                
                if let error = error {
                    // Don't treat cancellation as an error
                    let nsError = error as NSError
                    if nsError.domain != "kAFAssistantErrorDomain" || nsError.code != 216 {
                        self.error = .recognitionFailed(error.localizedDescription)
                    }
                    self.stopListening()
                }
            }
        }
        
        // Install audio tap
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, when in
            self?.recognitionRequest?.append(buffer)
            
            // Calculate audio level for waveform visualization
            let channelData = buffer.floatChannelData?[0]
            let frames = buffer.frameLength
            
            if let channelData = channelData {
                var sum: Float = 0
                for i in 0..<Int(frames) {
                    sum += abs(channelData[i])
                }
                let avgLevel = sum / Float(frames)
                
                Task { @MainActor in
                    self?.audioLevel = avgLevel
                }
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
    }
    
    // MARK: - Stop Listening
    
    func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // Finalize any remaining segment
        finalizeCurrentSegment()
        
        try? AVAudioSession.sharedInstance().setActive(false)
        
        isListening = false
    }
    
    // MARK: - Speaker Detection (Heuristic)
    
    /// Simple heuristic for speaker identification based on content
    /// In a real clinical setting, the doctor typically asks questions and the patient responds
    private func detectSpeaker(for text: String) -> TranscriptEntry.Speaker {
        let lowered = text.lowercased()
        
        // Doctor patterns — questions, medical terms, instructions
        let doctorPatterns = [
            "apa keluhan", "sejak kapan", "sudah berapa", "ada riwayat",
            "obat apa", "alergi", "periksa", "saya akan", "coba",
            "tekanan darah", "suhu", "nadi", "pernapasan",
            "diagnosis", "resep", "minum obat", "kontrol",
            "bisa ceritakan", "yang dirasakan", "bagaimana",
            "ada tidak", "apakah", "berapa kali", "berapa lama",
        ]
        
        // Patient patterns — complaints, descriptions
        let patientPatterns = [
            "saya merasa", "saya sakit", "sudah", "mulai",
            "tidak bisa", "susah", "sakit", "nyeri", "pusing",
            "demam", "batuk", "mual", "muntah", "diare",
            "anak saya", "suami saya", "istri saya",
            "dok", "dokter", "tolong",
        ]
        
        var doctorScore = 0
        var patientScore = 0
        
        for pattern in doctorPatterns {
            if lowered.contains(pattern) { doctorScore += 1 }
        }
        
        for pattern in patientPatterns {
            if lowered.contains(pattern) { patientScore += 1 }
        }
        
        if doctorScore > patientScore {
            return .doctor
        } else if patientScore > doctorScore {
            return .patient
        }
        
        // Alternate if no clear signal
        return lastSpeaker == .doctor ? .patient : .doctor
    }
    
    // MARK: - Private Helpers
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceThreshold, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.finalizeCurrentSegment()
            }
        }
    }
    
    private func finalizeCurrentSegment() {
        let trimmed = currentSegmentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let speaker = detectSpeaker(for: trimmed)
        let timestamp = startTime.map { Date().timeIntervalSince($0) } ?? 0
        
        let entry = TranscriptEntry(
            speaker: speaker,
            text: trimmed,
            timestamp: timestamp
        )
        
        transcriptEntries.append(entry)
        lastSpeaker = speaker
        currentSegmentText = ""
    }
    
    // MARK: - Reset
    
    func reset() {
        stopListening()
        currentTranscript = ""
        transcriptEntries = []
        audioLevel = 0.0
        error = nil
        lastTranscriptLength = 0
        currentSegmentText = ""
        lastSpeaker = .unknown
    }
    
    // MARK: - Computed
    
    var elapsedTime: TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }
}

// MARK: - Errors

enum SpeechError: LocalizedError {
    case notAuthorized
    case recognizerNotAvailable
    case requestCreationFailed
    case recognitionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Akses mikrofon belum diizinkan. Buka Pengaturan untuk mengaktifkan."
        case .recognizerNotAvailable:
            return "Pengenalan suara tidak tersedia untuk Bahasa Indonesia di perangkat ini."
        case .requestCreationFailed:
            return "Gagal membuat permintaan pengenalan suara."
        case .recognitionFailed(let message):
            return "Pengenalan suara gagal: \(message)"
        }
    }
}
