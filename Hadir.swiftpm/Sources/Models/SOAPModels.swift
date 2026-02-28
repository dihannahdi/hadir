import SwiftUI

// MARK: - SOAP Note Data Model

/// Represents a complete SOAP (Subjective, Objective, Assessment, Plan) clinical note
struct SOAPNote: Identifiable, Codable {
    let id: UUID
    var date: Date
    var subjective: SubjectiveNote
    var objective: ObjectiveNote
    var assessment: AssessmentNote
    var plan: PlanNote
    var transcript: [TranscriptEntry]
    var duration: TimeInterval
    var detectedSymptoms: [DetectedSymptom]
    var redFlagsTriggered: [RedFlag]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        subjective: SubjectiveNote = SubjectiveNote(),
        objective: ObjectiveNote = ObjectiveNote(),
        assessment: AssessmentNote = AssessmentNote(),
        plan: PlanNote = PlanNote(),
        transcript: [TranscriptEntry] = [],
        duration: TimeInterval = 0,
        detectedSymptoms: [DetectedSymptom] = [],
        redFlagsTriggered: [RedFlag] = []
    ) {
        self.id = id
        self.date = date
        self.subjective = subjective
        self.objective = objective
        self.assessment = assessment
        self.plan = plan
        self.transcript = transcript
        self.duration = duration
        self.detectedSymptoms = detectedSymptoms
        self.redFlagsTriggered = redFlagsTriggered
    }
    
    /// Estimated time saved by using Hadir (in seconds)
    var estimatedTimeSaved: TimeInterval {
        // Average typing time for SOAP note: ~8 minutes
        // With Hadir: review only ~2 minutes
        return max(360, duration * 0.6) // At least 6 minutes saved
    }
    
    /// Check if the note is sufficiently complete
    var isComplete: Bool {
        !subjective.chiefComplaint.isEmpty && !assessment.primaryDiagnosis.isEmpty
    }
}

// MARK: - Subjective Component

struct SubjectiveNote: Codable {
    var chiefComplaint: String = ""
    var historyOfPresentIllness: String = ""
    var symptomDuration: String = ""
    var associatedSymptoms: [String] = []
    var medicationsTried: [String] = []
    var allergies: String = ""
    
    var summary: String {
        var parts: [String] = []
        if !chiefComplaint.isEmpty { parts.append("KU: \(chiefComplaint)") }
        if !historyOfPresentIllness.isEmpty { parts.append("RPS: \(historyOfPresentIllness)") }
        if !symptomDuration.isEmpty { parts.append("Durasi: \(symptomDuration)") }
        if !associatedSymptoms.isEmpty { parts.append("Gejala penyerta: \(associatedSymptoms.joined(separator: ", "))") }
        if !medicationsTried.isEmpty { parts.append("Obat yang sudah dicoba: \(medicationsTried.joined(separator: ", "))") }
        return parts.joined(separator: ". ")
    }
}

// MARK: - Objective Component

struct ObjectiveNote: Codable {
    var vitalSigns: VitalSigns = VitalSigns()
    var physicalExamFindings: String = ""
    var generalAppearance: String = ""
    
    var summary: String {
        var parts: [String] = []
        parts.append("KU: \(generalAppearance.isEmpty ? "Compos mentis" : generalAppearance)")
        parts.append("TTV: \(vitalSigns.summary)")
        if !physicalExamFindings.isEmpty { parts.append("PF: \(physicalExamFindings)") }
        return parts.joined(separator: ". ")
    }
}

struct VitalSigns: Codable {
    var temperature: String = ""
    var bloodPressure: String = ""
    var heartRate: String = ""
    var respiratoryRate: String = ""
    var oxygenSaturation: String = ""
    
    var summary: String {
        var parts: [String] = []
        if !temperature.isEmpty { parts.append("S: \(temperature)°C") }
        if !bloodPressure.isEmpty { parts.append("TD: \(bloodPressure) mmHg") }
        if !heartRate.isEmpty { parts.append("HR: \(heartRate) x/m") }
        if !respiratoryRate.isEmpty { parts.append("RR: \(respiratoryRate) x/m") }
        if !oxygenSaturation.isEmpty { parts.append("SpO2: \(oxygenSaturation)%") }
        return parts.isEmpty ? "Belum diukur" : parts.joined(separator: ", ")
    }
}

// MARK: - Assessment Component

struct AssessmentNote: Codable {
    var primaryDiagnosis: String = ""
    var icdCode: String = ""
    var differentialDiagnoses: [String] = []
    var severity: Severity = .mild
    
    var summary: String {
        var parts: [String] = []
        if !primaryDiagnosis.isEmpty {
            var diag = primaryDiagnosis
            if !icdCode.isEmpty { diag += " (\(icdCode))" }
            parts.append(diag)
        }
        if !differentialDiagnoses.isEmpty {
            parts.append("DD: \(differentialDiagnoses.joined(separator: ", "))")
        }
        return parts.joined(separator: ". ")
    }
    
    enum Severity: String, Codable, CaseIterable {
        case mild = "Ringan"
        case moderate = "Sedang"
        case severe = "Berat"
        case critical = "Kritis"
    }
}

// MARK: - Plan Component

struct PlanNote: Codable {
    var medications: [Medication] = []
    var labOrders: [String] = []
    var referral: String = ""
    var education: String = ""
    var followUp: String = ""
    
    var summary: String {
        var parts: [String] = []
        if !medications.isEmpty {
            let meds = medications.map { $0.description }.joined(separator: "; ")
            parts.append("Rx: \(meds)")
        }
        if !labOrders.isEmpty { parts.append("Lab: \(labOrders.joined(separator: ", "))") }
        if !referral.isEmpty { parts.append("Rujuk: \(referral)") }
        if !education.isEmpty { parts.append("KIE: \(education)") }
        if !followUp.isEmpty { parts.append("Kontrol: \(followUp)") }
        return parts.joined(separator: ". ")
    }
}

struct Medication: Codable, Identifiable {
    let id: UUID
    var name: String
    var dose: String
    var frequency: String
    var duration: String
    
    init(id: UUID = UUID(), name: String, dose: String = "", frequency: String = "", duration: String = "") {
        self.id = id
        self.name = name
        self.dose = dose
        self.frequency = frequency
        self.duration = duration
    }
    
    var description: String {
        var parts = [name]
        if !dose.isEmpty { parts.append(dose) }
        if !frequency.isEmpty { parts.append(frequency) }
        if !duration.isEmpty { parts.append(duration) }
        return parts.joined(separator: " ")
    }
}

// MARK: - Transcript Models

struct TranscriptEntry: Identifiable, Codable {
    let id: UUID
    let speaker: Speaker
    let text: String
    let timestamp: TimeInterval
    var highlightedTerms: [HighlightedTerm]
    
    init(id: UUID = UUID(), speaker: Speaker, text: String, timestamp: TimeInterval, highlightedTerms: [HighlightedTerm] = []) {
        self.id = id
        self.speaker = speaker
        self.text = text
        self.timestamp = timestamp
        self.highlightedTerms = highlightedTerms
    }
    
    enum Speaker: String, Codable {
        case doctor = "Dokter"
        case patient = "Pasien"
        case unknown = "Unknown"
    }
}

struct HighlightedTerm: Codable, Identifiable {
    let id: UUID
    let term: String
    let category: TermCategory
    var range: Range<String.Index>?
    
    init(id: UUID = UUID(), term: String, category: TermCategory, range: Range<String.Index>? = nil) {
        self.id = id
        self.term = term
        self.category = category
        self.range = range
    }
    
    enum TermCategory: String, Codable {
        case symptom = "Gejala"
        case medication = "Obat"
        case duration = "Durasi"
        case bodyPart = "Bagian Tubuh"
        case vitalSign = "Tanda Vital"
        case redFlag = "Red Flag"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, term, category
    }
}

// MARK: - Detected Symptom

struct DetectedSymptom: Identifiable, Codable {
    let id: UUID
    let name: String
    let indonesianName: String
    let confidence: Double
    let timestamp: TimeInterval
    
    init(id: UUID = UUID(), name: String, indonesianName: String = "", confidence: Double = 1.0, timestamp: TimeInterval = 0) {
        self.id = id
        self.name = name
        self.indonesianName = indonesianName.isEmpty ? name : indonesianName
        self.confidence = confidence
        self.timestamp = timestamp
    }
}

// MARK: - Red Flag

struct RedFlag: Identifiable, Codable {
    let id: UUID
    let condition: String
    let symptoms: [String]
    let urgencyLevel: UrgencyLevel
    let action: String
    
    init(id: UUID = UUID(), condition: String, symptoms: [String], urgencyLevel: UrgencyLevel = .high, action: String = "") {
        self.id = id
        self.condition = condition
        self.symptoms = symptoms
        self.urgencyLevel = urgencyLevel
        self.action = action
    }
    
    enum UrgencyLevel: String, Codable {
        case moderate = "Sedang"
        case high = "Tinggi"
        case critical = "Kritis"
    }
}

// MARK: - Consultation Session

struct ConsultationSession: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var soapNote: SOAPNote
    var status: SessionStatus
    
    init(id: UUID = UUID(), startTime: Date = Date()) {
        self.id = id
        self.startTime = startTime
        self.endTime = nil
        self.soapNote = SOAPNote()
        self.status = .active
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    enum SessionStatus: String, Codable {
        case active = "Aktif"
        case paused = "Dijeda"
        case completed = "Selesai"
    }
}

// MARK: - Daily Statistics

struct DailyStatistics: Codable {
    var date: Date
    var totalConsultations: Int
    var totalTimeSaved: TimeInterval
    var redFlagsDetected: Int
    var symptomsDetected: Int
    
    init(date: Date = Date(), totalConsultations: Int = 0, totalTimeSaved: TimeInterval = 0, redFlagsDetected: Int = 0, symptomsDetected: Int = 0) {
        self.date = date
        self.totalConsultations = totalConsultations
        self.totalTimeSaved = totalTimeSaved
        self.redFlagsDetected = redFlagsDetected
        self.symptomsDetected = symptomsDetected
    }
    
    var timeSavedMinutes: Int {
        Int(totalTimeSaved / 60)
    }
}
