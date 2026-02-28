import Foundation

// MARK: - SOAP Note Generator
// Automatically assembles SOAP notes from transcript and NLP analysis

@MainActor
class SOAPNoteGenerator: ObservableObject {
    
    // MARK: - Published
    
    @Published var currentNote = SOAPNote()
    @Published var diagnosisSuggestions: [DiagnosisSuggestion] = []
    @Published var detectedRedFlags: [RedFlag] = []
    @Published var allDetectedSymptoms: [DetectedSymptom] = []
    @Published var isProcessing = false
    
    // MARK: - Dependencies
    
    private let nlpExtractor = NLPSymptomExtractor.shared
    private var processedEntryIds: Set<UUID> = []
    
    // MARK: - Process Transcript Entries
    
    /// Process new transcript entries and update SOAP note in real-time
    func processTranscriptEntries(_ entries: [TranscriptEntry]) {
        isProcessing = true
        
        for entry in entries {
            // Skip already processed
            guard !processedEntryIds.contains(entry.id) else { continue }
            processedEntryIds.insert(entry.id)
            
            // Extract medical entities
            let extraction = nlpExtractor.extractMedicalEntities(from: entry.text)
            
            // Update transcript entry with highlights
            var updatedEntry = entry
            updatedEntry.highlightedTerms = extraction.highlightedTerms
            
            // Update the entry in the note's transcript
            if let idx = currentNote.transcript.firstIndex(where: { $0.id == entry.id }) {
                currentNote.transcript[idx] = updatedEntry
            } else {
                currentNote.transcript.append(updatedEntry)
            }
            
            // Add detected symptoms
            for symptom in extraction.symptoms {
                if !allDetectedSymptoms.contains(where: { $0.indonesianName == symptom.indonesianName }) {
                    allDetectedSymptoms.append(symptom)
                }
            }
            currentNote.detectedSymptoms = allDetectedSymptoms
            
            // Update SOAP components based on speaker
            switch entry.speaker {
            case .patient:
                updateSubjective(from: entry.text, extraction: extraction)
            case .doctor:
                updateObjective(from: entry.text, extraction: extraction)
            case .unknown:
                updateSubjective(from: entry.text, extraction: extraction)
            }
            
            // Check red flags (deterministic)
            let newFlags = nlpExtractor.checkRedFlags(symptoms: allDetectedSymptoms)
            for flag in newFlags {
                if !detectedRedFlags.contains(where: { $0.condition == flag.condition }) {
                    detectedRedFlags.append(flag)
                    currentNote.redFlagsTriggered = detectedRedFlags
                }
            }
            
            // Update diagnosis suggestions
            diagnosisSuggestions = nlpExtractor.suggestDiagnoses(symptoms: allDetectedSymptoms)
            
            // Update assessment with top suggestion
            if let topDiagnosis = diagnosisSuggestions.first {
                currentNote.assessment.primaryDiagnosis = topDiagnosis.name
                currentNote.assessment.icdCode = topDiagnosis.icdCode
                currentNote.assessment.differentialDiagnoses = Array(diagnosisSuggestions.dropFirst().prefix(3).map { $0.name })
            }
            
            // Update plan from top diagnosis
            if let topDiagnosis = diagnosisSuggestions.first {
                currentNote.plan.education = topDiagnosis.management
                currentNote.plan.medications = topDiagnosis.medications.prefix(3).map {
                    Medication(name: $0)
                }
            }
        }
        
        isProcessing = false
    }
    
    // MARK: - Update Subjective (from patient speech)
    
    private func updateSubjective(from text: String, extraction: ExtractionResult) {
        // Build chief complaint from symptoms
        if currentNote.subjective.chiefComplaint.isEmpty && !extraction.symptoms.isEmpty {
            let symptoms = extraction.symptoms.map { $0.indonesianName }.joined(separator: ", ")
            currentNote.subjective.chiefComplaint = symptoms
        } else if !extraction.symptoms.isEmpty {
            // Append new symptoms
            let existing = Set(currentNote.subjective.associatedSymptoms)
            let newSymptoms = extraction.symptoms.map { $0.indonesianName }.filter { !existing.contains($0) }
            currentNote.subjective.associatedSymptoms.append(contentsOf: newSymptoms)
        }
        
        // Update duration
        if !extraction.durations.isEmpty {
            currentNote.subjective.symptomDuration = extraction.durations.first ?? ""
        }
        
        // Update medications tried
        if !extraction.medications.isEmpty {
            let existing = Set(currentNote.subjective.medicationsTried)
            let newMeds = extraction.medications.filter { !existing.contains($0) }
            currentNote.subjective.medicationsTried.append(contentsOf: newMeds)
        }
        
        // Update HPI
        if !text.isEmpty {
            if currentNote.subjective.historyOfPresentIllness.isEmpty {
                currentNote.subjective.historyOfPresentIllness = text
            } else {
                currentNote.subjective.historyOfPresentIllness += " \(text)"
            }
        }
    }
    
    // MARK: - Update Objective (from doctor speech)
    
    private func updateObjective(from text: String, extraction: ExtractionResult) {
        let lowered = text.lowercased()
        
        // Extract vital signs from speech
        extractVitalSigns(from: lowered)
        
        // Physical exam findings
        if lowered.contains("pemeriksaan") || lowered.contains("periksa") || lowered.contains("inspeksi") ||
            lowered.contains("palpasi") || lowered.contains("auskultasi") || lowered.contains("perkusi") {
            if currentNote.objective.physicalExamFindings.isEmpty {
                currentNote.objective.physicalExamFindings = text
            } else {
                currentNote.objective.physicalExamFindings += ". \(text)"
            }
        }
        
        // General appearance
        if lowered.contains("compos mentis") || lowered.contains("tampak sakit") || lowered.contains("kesan umum") {
            currentNote.objective.generalAppearance = text
        }
    }
    
    // MARK: - Extract Vital Signs from Speech
    
    private func extractVitalSigns(from text: String) {
        // Temperature
        if let match = extractNumber(from: text, after: ["suhu", "temperatur", "temp"]) {
            currentNote.objective.vitalSigns.temperature = match
        }
        
        // Blood Pressure
        let bpPattern = "\\d{2,3}[/\\\\]\\d{2,3}"
        if let regex = try? NSRegularExpression(pattern: bpPattern),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range, in: text) {
            currentNote.objective.vitalSigns.bloodPressure = String(text[range])
        }
        
        // Heart Rate
        if let match = extractNumber(from: text, after: ["nadi", "heart rate", "hr", "denyut"]) {
            currentNote.objective.vitalSigns.heartRate = match
        }
        
        // Respiratory Rate
        if let match = extractNumber(from: text, after: ["napas", "respiratory", "rr", "pernapasan"]) {
            currentNote.objective.vitalSigns.respiratoryRate = match
        }
        
        // SpO2
        if let match = extractNumber(from: text, after: ["saturasi", "spo2", "oksigen"]) {
            currentNote.objective.vitalSigns.oxygenSaturation = match
        }
    }
    
    private func extractNumber(from text: String, after keywords: [String]) -> String? {
        for keyword in keywords {
            if text.contains(keyword) {
                let pattern = "\(keyword)\\s*:?\\s*(\\d+[.,]?\\d*)"
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                   let numRange = Range(match.range(at: 1), in: text) {
                    return String(text[numRange])
                }
            }
        }
        return nil
    }
    
    // MARK: - Finalize Note
    
    func finalizeNote(duration: TimeInterval) -> SOAPNote {
        currentNote.duration = duration
        currentNote.date = Date()
        return currentNote
    }
    
    // MARK: - Reset
    
    func reset() {
        currentNote = SOAPNote()
        diagnosisSuggestions = []
        detectedRedFlags = []
        allDetectedSymptoms = []
        processedEntryIds = []
        isProcessing = false
    }
}
