#!/usr/bin/env swift
// Hadir — Standalone Algorithm Tests
// Run with: swift Tests/HadirAlgorithmTests.swift
// No XCTest, no iOS frameworks — tests pure logic that mirrors the app
// CI command: swift Hadir.swiftpm/Tests/HadirAlgorithmTests.swift

import Foundation

// ─────────────────────────────────────────────────────────
// MARK: - Minimal Test Harness
// ─────────────────────────────────────────────────────────

var passed = 0
var failed = 0
var currentSuite = ""

func suite(_ name: String) {
    currentSuite = name
    print("\n  \(name)")
    print("  " + String(repeating: "─", count: name.count))
}

func check(_ condition: Bool, _ desc: String, file: String = #file, line: Int = #line) {
    if condition {
        print("    ✓  \(desc)")
        passed += 1
    } else {
        print("    ✗  FAILED: \(desc)  [\(URL(fileURLWithPath: file).lastPathComponent):\(line)]")
        failed += 1
    }
}

func checkEqual<T: Equatable>(_ a: T, _ b: T, _ desc: String, file: String = #file, line: Int = #line) {
    check(a == b, "\(desc) — expected \(b), got \(a)", file: file, line: line)
}

// ─────────────────────────────────────────────────────────
// MARK: - Inline Symptom Keyword Table (mirrors MedicalKnowledgeBase)
// ─────────────────────────────────────────────────────────

let symptomKeywords: [String: String] = [
    "demam": "Fever", "panas": "Fever", "meriang": "Fever/Chills",
    "batuk": "Cough", "batuk berdahak": "Productive cough", "batuk kering": "Dry cough",
    "sesak napas": "Dyspnea", "sesak": "Dyspnea", "mengi": "Wheezing",
    "nyeri dada": "Chest pain", "sakit dada": "Chest pain", "dada terasa berat": "Chest heaviness",
    "jantung berdebar": "Palpitations", "keringat dingin": "Cold sweats",
    "sakit kepala": "Headache", "nyeri kepala": "Headache",
    "kejang": "Seizure", "pingsan": "Syncope",
    "mual": "Nausea", "muntah": "Vomiting", "diare": "Diarrhea",
    "pusing": "Dizziness", "lemas": "Weakness", "lelah": "Fatigue",
    "gatal": "Pruritus", "ruam": "Rash", "bentol": "Urticaria",
    "nyeri sendi": "Arthralgia", "nyeri otot": "Myalgia", "pegal": "Myalgia",
    "lemah separuh badan": "Hemiparesis", "bicara pelo": "Dysarthria",
    "pandangan kabur": "Blurred vision", "bengkak": "Edema",
    "nyeri kencing": "Dysuria", "sering kencing": "Frequency",
    "batuk darah": "Hemoptysis", "bab berdarah": "Hematochezia",
]

// ─────────────────────────────────────────────────────────
// MARK: - Symptom Extraction (mirrors NLPSymptomExtractor)
// ─────────────────────────────────────────────────────────

func extractSymptoms(from text: String) -> [String] {
    let lower = text.lowercased()
    return symptomKeywords.keys.filter { lower.contains($0) }.sorted()
}

// ─────────────────────────────────────────────────────────
// MARK: - Red Flag Rules (mirrors MedicalKnowledgeBase)
// ─────────────────────────────────────────────────────────

struct RFRule { let name: String; let triggers: [String]; let minMatch: Int }

let redFlagRules: [RFRule] = [
    RFRule(name: "Acute Coronary Syndrome",
           triggers: ["nyeri dada", "sesak napas", "keringat dingin"], minMatch: 2),
    RFRule(name: "Stroke",
           triggers: ["lemah separuh badan", "bicara pelo", "pandangan kabur", "sakit kepala"], minMatch: 2),
    RFRule(name: "Meningitis",
           triggers: ["demam", "sakit kepala", "kejang"], minMatch: 3),
    RFRule(name: "Asthma Exacerbation",
           triggers: ["sesak napas", "mengi", "batuk"], minMatch: 2),
    RFRule(name: "Dengue Warning Signs",
           triggers: ["demam", "nyeri otot", "mual", "lemas", "bab berdarah"], minMatch: 3),
    RFRule(name: "Respiratory Distress",
           triggers: ["sesak napas", "batuk darah", "demam"], minMatch: 2),
    RFRule(name: "Anaphylaxis",
           triggers: ["sesak napas", "bentol", "bengkak", "pusing"], minMatch: 3),
]

func checkRedFlags(symptoms: [String]) -> [String] {
    let set = Set(symptoms)
    return redFlagRules.compactMap { rule -> String? in
        let matches = rule.triggers.filter { set.contains($0) }.count
        return matches >= rule.minMatch ? rule.name : nil
    }
}

// ─────────────────────────────────────────────────────────
// MARK: - Duration Extraction (mirrors NLPSymptomExtractor)
// ─────────────────────────────────────────────────────────

func extractDurations(from text: String) -> [String] {
    var results: [String] = []
    let patterns = [
        "\\d+\\s*(hari|minggu|bulan|tahun|jam)",
        "se(minggu|bulan|tahun|hari)",
        "sudah\\s+\\d+\\s*(hari|minggu|bulan)",
        "sejak\\s+(kemarin|tadi|pagi|sore|malam|semalam)",
    ]
    for pattern in patterns {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }
        let range = NSRange(text.startIndex..., in: text)
        regex.matches(in: text, range: range).forEach {
            if let r = Range($0.range, in: text) { results.append(String(text[r])) }
        }
    }
    return results
}

// ─────────────────────────────────────────────────────────
// MARK: - Diagnosis Scoring (mirrors NLPSymptomExtractor)
// ─────────────────────────────────────────────────────────

struct Dx { let name: String; let icd: String; let symptoms: [String] }

let diagnoses: [Dx] = [
    Dx(name: "ISPA", icd: "J06.9", symptoms: ["batuk", "pilek", "demam", "sakit tenggorokan"]),
    Dx(name: "Gastritis", icd: "K30", symptoms: ["nyeri perut", "mual", "kembung"]),
    Dx(name: "Hipertensi", icd: "I10", symptoms: ["sakit kepala", "pusing", "pandangan kabur"]),
    Dx(name: "Asma", icd: "J45.9", symptoms: ["sesak napas", "mengi", "batuk", "dada terasa berat"]),
    Dx(name: "Demam Dengue", icd: "A90", symptoms: ["demam", "nyeri otot", "sakit kepala", "ruam"]),
]

func suggestDiagnoses(symptoms: [String]) -> [(name: String, confidence: Double)] {
    let set = Set(symptoms)
    return diagnoses.compactMap { dx -> (String, Double)? in
        let matches = dx.symptoms.filter { set.contains($0) }.count
        guard matches > 0 else { return nil }
        return (dx.name, Double(matches) / Double(dx.symptoms.count))
    }.sorted { $0.1 > $1.1 }
}

// ─────────────────────────────────────────────────────────
// MARK: - ❶ Symptom Extraction Tests
// ─────────────────────────────────────────────────────────

suite("Symptom Extraction")

check(extractSymptoms(from: "saya demam sejak 3 hari").contains("demam"),
      "detects 'demam' in normal sentence")

check(extractSymptoms(from: "sudah batuk berdahak seminggu ini").contains("batuk berdahak"),
      "detects multi-word symptom 'batuk berdahak'")

check(extractSymptoms(from: "saya mengalami sesak napas dan nyeri dada").contains("nyeri dada"),
      "detects 'nyeri dada'")

check(extractSymptoms(from: "DEMAM TINGGI SEKALI").contains("demam"),
      "case-insensitive matching")

check(extractSymptoms(from: "hari ini saya baik-baik saja").isEmpty,
      "returns empty for no symptoms")

check(extractSymptoms(from: "mual, muntah, dan diare sejak kemarin").count >= 3,
      "detects multiple symptoms in one sentence")

check(extractSymptoms(from: "lemah separuh badan dan bicara pelo").contains("lemah separuh badan"),
      "detects long-form stroke symptom")

// ─────────────────────────────────────────────────────────
// MARK: - ❷ Red Flag Detection Tests
// ─────────────────────────────────────────────────────────

suite("Red Flag Detection")

let acsSymptoms = ["nyeri dada", "sesak napas", "keringat dingin"]
check(checkRedFlags(symptoms: acsSymptoms).contains("Acute Coronary Syndrome"),
      "ACS triggered with 3/3 symptoms")

check(checkRedFlags(symptoms: ["nyeri dada", "keringat dingin"]).contains("Acute Coronary Syndrome"),
      "ACS triggered with 2/3 symptoms (meets minMatch=2)")

check(!checkRedFlags(symptoms: ["nyeri dada"]).contains("Acute Coronary Syndrome"),
      "ACS NOT triggered with 1/3 symptoms")

let strokeSymptoms = ["lemah separuh badan", "bicara pelo"]
check(checkRedFlags(symptoms: strokeSymptoms).contains("Stroke"),
      "Stroke triggered with 2/4 symptoms (meets minMatch=2)")

check(!checkRedFlags(symptoms: ["demam", "sakit kepala"]).contains("Meningitis"),
      "Meningitis NOT triggered without 'kejang' (needs 3 matches)")

check(checkRedFlags(symptoms: ["demam", "sakit kepala", "kejang"]).contains("Meningitis"),
      "Meningitis triggered with exactly 3/3 required symptoms")

check(checkRedFlags(symptoms: ["sesak napas", "mengi", "batuk"]).contains("Asthma Exacerbation"),
      "Asthma exacerbation triggered")

check(checkRedFlags(symptoms: []).isEmpty,
      "no red flags for empty symptom list")

// ─────────────────────────────────────────────────────────
// MARK: - ❸ Duration Extraction Tests
// ─────────────────────────────────────────────────────────

suite("Duration Extraction")

check(extractDurations(from: "sudah 3 hari demam").contains("3 hari"),
      "extracts '3 hari'")

check(!extractDurations(from: "sudah 2 minggu batuk").filter { $0.contains("minggu") }.isEmpty,
      "extracts '2 minggu'")

check(!extractDurations(from: "sejak kemarin pusing").filter { $0.contains("kemarin") }.isEmpty,
      "extracts 'sejak kemarin'")

check(!extractDurations(from: "seminggu yang lalu").filter { $0.contains("seminggu") }.isEmpty,
      "extracts 'seminggu'")

check(extractDurations(from: "saya tidak tahu kapan mulainya").isEmpty,
      "no duration extracted from vague sentence")

// ─────────────────────────────────────────────────────────
// MARK: - ❹ Diagnosis Scoring Tests
// ─────────────────────────────────────────────────────────

suite("Diagnosis Scoring")

let asmaSymptoms = ["sesak napas", "mengi", "batuk", "dada terasa berat"]
let asmaResult = suggestDiagnoses(symptoms: asmaSymptoms)
check(asmaResult.first?.name == "Asma",
      "Asma ranks first with 4/4 matched symptoms (100% confidence)")
check(abs((asmaResult.first?.confidence ?? 0) - 1.0) < 0.001,
      "Asma confidence = 1.0 with all 4 symptoms matched")

let ispaSymptoms = ["batuk", "demam"]
let ispaResult = suggestDiagnoses(symptoms: ispaSymptoms)
check(ispaResult.contains(where: { $0.name == "ISPA" }),
      "ISPA appears in diagnosis suggestions with partial match")

check(suggestDiagnoses(symptoms: ["pusing", "pandangan kabur"]).contains(where: { $0.name == "Hipertensi" }),
      "Hipertensi suggested for neurological symptoms")

check(suggestDiagnoses(symptoms: []).isEmpty,
      "no diagnoses suggested for empty symptoms")

// ─────────────────────────────────────────────────────────
// MARK: - ❺ Speaker Detection Heuristics
// ─────────────────────────────────────────────────────────

suite("Speaker Detection")

func detectSpeaker(_ text: String) -> String {
    let lower = text.lowercased()
    let doctorPatterns = ["apa keluhan", "sejak kapan", "sudah berapa", "ada riwayat",
                          "tekanan darah", "periksa", "saya akan", "diagnosis"]
    let patientPatterns = ["saya merasa", "saya sakit", "dok ", "dokter", "tolong",
                           "sakit", "nyeri", "pusing", "demam", "batuk"]
    let ds = doctorPatterns.filter { lower.contains($0) }.count
    let ps = patientPatterns.filter { lower.contains($0) }.count
    if ds > ps { return "doctor" }
    if ps > ds { return "patient" }
    return "unknown"
}

checkEqual(detectSpeaker("Apa keluhan utama bapak hari ini?"), "doctor",
           "recognizes doctor question pattern")

checkEqual(detectSpeaker("Dok, saya sakit kepala dan demam tinggi"), "patient",
           "recognizes patient complaint pattern")

checkEqual(detectSpeaker("Tekanan darah 130 per 80, periksa denyut nadi"), "doctor",
           "recognizes doctor objective recording")

// ─────────────────────────────────────────────────────────
// MARK: - ❻ Knowledge Base Completeness
// ─────────────────────────────────────────────────────────

suite("Knowledge Base Completeness")

check(symptomKeywords.count >= 35,
      "KB has at least 35 symptom keywords (got \(symptomKeywords.count))")

check(redFlagRules.count >= 7,
      "KB has at least 7 red flag rules (got \(redFlagRules.count))")

check(diagnoses.count >= 5,
      "KB has at least 5 diagnosis entries (got \(diagnoses.count))")

// Every red flag rule should have valid minMatch
for rule in redFlagRules {
    check(rule.minMatch <= rule.triggers.count,
          "'\(rule.name)': minMatch (\(rule.minMatch)) ≤ trigger count (\(rule.triggers.count))")
    check(rule.minMatch >= 1,
          "'\(rule.name)': minMatch ≥ 1")
}

// ─────────────────────────────────────────────────────────
// MARK: - Results
// ─────────────────────────────────────────────────────────

let total = passed + failed
let bar = String(repeating: "─", count: 52)
print("\n  \(bar)")
if failed == 0 {
    print("  ✅ ALL \(total) TESTS PASSED")
} else {
    print("  ❌ \(failed)/\(total) TESTS FAILED")
}
print("  \(bar)\n")

exit(failed > 0 ? 1 : 0)
