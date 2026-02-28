import Foundation
import NaturalLanguage

// MARK: - NLP Symptom Extraction Service
// Uses Apple's Natural Language framework for Named Entity Recognition
// Extracts symptoms, medications, durations, and body parts from Indonesian medical text

class NLPSymptomExtractor {
    
    // MARK: - Singleton
    
    static let shared = NLPSymptomExtractor()
    
    // MARK: - Properties
    
    private let tagger: NLTagger
    private let knowledgeBase = MedicalKnowledgeBase.self
    
    // MARK: - Initialization
    
    private init() {
        tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .language])
    }
    
    // MARK: - Main Extraction Method
    
    /// Extract all medical entities from a text string
    func extractMedicalEntities(from text: String) -> ExtractionResult {
        let lowered = text.lowercased()
        
        var symptoms: [DetectedSymptom] = []
        var medications: [String] = []
        var durations: [String] = []
        var bodyParts: [String] = []
        var highlightedTerms: [HighlightedTerm] = []
        
        // 1. Extract symptoms
        for (keyword, info) in knowledgeBase.symptomKeywords {
            if lowered.contains(keyword) {
                let symptom = DetectedSymptom(
                    name: info.medical,
                    indonesianName: keyword,
                    confidence: 1.0
                )
                symptoms.append(symptom)
                
                if let range = lowered.range(of: keyword) {
                    highlightedTerms.append(HighlightedTerm(
                        term: keyword,
                        category: info.category == .cardiovascular || keyword == "kejang" ? .redFlag : .symptom,
                        range: range
                    ))
                }
            }
        }
        
        // 2. Extract medications
        for med in knowledgeBase.medicationKeywords {
            if lowered.contains(med) {
                medications.append(med)
                if let range = lowered.range(of: med) {
                    highlightedTerms.append(HighlightedTerm(
                        term: med,
                        category: .medication,
                        range: range
                    ))
                }
            }
        }
        
        // 3. Extract durations
        let durationPatterns = extractDurations(from: lowered)
        durations.append(contentsOf: durationPatterns)
        for dur in durationPatterns {
            highlightedTerms.append(HighlightedTerm(
                term: dur,
                category: .duration
            ))
        }
        
        // 4. Extract body parts
        for part in knowledgeBase.bodyPartKeywords {
            if lowered.contains(part) {
                bodyParts.append(part)
                if let range = lowered.range(of: part) {
                    highlightedTerms.append(HighlightedTerm(
                        term: part,
                        category: .bodyPart,
                        range: range
                    ))
                }
            }
        }
        
        // 5. Use NLTagger for additional NER
        let nlpEntities = extractUsingNLTagger(text: text)
        
        return ExtractionResult(
            symptoms: symptoms,
            medications: medications,
            durations: durations,
            bodyParts: bodyParts,
            highlightedTerms: highlightedTerms,
            nlpEntities: nlpEntities
        )
    }
    
    // MARK: - Duration Extraction
    
    private func extractDurations(from text: String) -> [String] {
        var durations: [String] = []
        
        // Pattern: number + time unit
        let patterns = [
            "\\d+\\s*(hari|minggu|bulan|tahun|jam)",
            "se(minggu|bulan|tahun|hari)",
            "sejak\\s+(kemarin|tadi|pagi|sore|malam|subuh|semalam)",
            "sudah\\s+\\d+\\s*(hari|minggu|bulan)",
            "(tiga|dua|empat|lima|enam|tujuh)\\s*(hari|minggu|bulan)",
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                let matches = regex.matches(in: text, range: range)
                for match in matches {
                    if let swiftRange = Range(match.range, in: text) {
                        durations.append(String(text[swiftRange]))
                    }
                }
            }
        }
        
        return durations
    }
    
    // MARK: - NLTagger Extraction
    
    private func extractUsingNLTagger(text: String) -> [NLPEntity] {
        var entities: [NLPEntity] = []
        
        tagger.string = text
        
        // Tag lexical classes to identify nouns, verbs, adjectives
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                let word = String(text[tokenRange])
                entities.append(NLPEntity(
                    text: word,
                    tag: tag.rawValue,
                    range: tokenRange
                ))
            }
            return true
        }
        
        return entities
    }
    
    // MARK: - Red Flag Detection
    
    /// Check extracted symptoms against Red Flag rules
    /// This is DETERMINISTIC — rule-based, not AI guessing
    func checkRedFlags(symptoms: [DetectedSymptom]) -> [RedFlag] {
        var triggeredFlags: [RedFlag] = []
        
        let symptomNames = Set(symptoms.map { $0.indonesianName.lowercased() })
        
        for rule in knowledgeBase.redFlagRules {
            let matchCount = rule.triggerSymptoms.filter { symptomNames.contains($0) }.count
            
            if matchCount >= rule.minimumMatch {
                let flag = RedFlag(
                    condition: rule.name,
                    symptoms: rule.triggerSymptoms.filter { symptomNames.contains($0) },
                    urgencyLevel: rule.urgency,
                    action: rule.action
                )
                triggeredFlags.append(flag)
            }
        }
        
        return triggeredFlags
    }
    
    // MARK: - Diagnosis Suggestion
    
    /// Suggest diagnoses based on detected symptoms — grounded to PPK database
    func suggestDiagnoses(symptoms: [DetectedSymptom]) -> [DiagnosisSuggestion] {
        let symptomNames = Set(symptoms.map { $0.indonesianName.lowercased() })
        
        var suggestions: [DiagnosisSuggestion] = []
        
        for diagnosis in knowledgeBase.commonDiagnoses {
            let matchCount = diagnosis.commonSymptoms.filter { symptomNames.contains($0) }.count
            
            if matchCount > 0 {
                let confidence = Double(matchCount) / Double(diagnosis.commonSymptoms.count)
                suggestions.append(DiagnosisSuggestion(
                    name: diagnosis.name,
                    icdCode: diagnosis.icdCode,
                    confidence: confidence,
                    matchedSymptoms: diagnosis.commonSymptoms.filter { symptomNames.contains($0) },
                    management: diagnosis.management,
                    medications: diagnosis.fornasMedications
                ))
            }
        }
        
        // Sort by confidence descending
        return suggestions.sorted { $0.confidence > $1.confidence }
    }
}

// MARK: - Supporting Types

struct ExtractionResult {
    let symptoms: [DetectedSymptom]
    let medications: [String]
    let durations: [String]
    let bodyParts: [String]
    let highlightedTerms: [HighlightedTerm]
    let nlpEntities: [NLPEntity]
}

struct NLPEntity {
    let text: String
    let tag: String
    let range: Range<String.Index>
}

struct DiagnosisSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let icdCode: String
    let confidence: Double
    let matchedSymptoms: [String]
    let management: String
    let medications: [String]
    
    var confidencePercentage: Int {
        Int(confidence * 100)
    }
}
