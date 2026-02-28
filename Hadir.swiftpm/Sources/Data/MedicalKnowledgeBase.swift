import Foundation

// MARK: - Medical Knowledge Base
// PPK (Panduan Praktik Klinis) grounded data for Indonesian Puskesmas
// All data bundled on-device — no internet required

struct MedicalKnowledgeBase {
    
    // MARK: - Symptom Database (Bahasa Indonesia)
    
    /// Common symptoms with Indonesian terms and their medical equivalents
    static let symptomKeywords: [String: SymptomInfo] = [
        // Gejala Umum
        "demam": SymptomInfo(medical: "Fever", category: .general, icdHint: "R50.9"),
        "panas": SymptomInfo(medical: "Fever", category: .general, icdHint: "R50.9"),
        "meriang": SymptomInfo(medical: "Fever/Chills", category: .general, icdHint: "R50.9"),
        "menggigil": SymptomInfo(medical: "Chills", category: .general, icdHint: "R68.83"),
        "lemas": SymptomInfo(medical: "Weakness/Malaise", category: .general, icdHint: "R53.1"),
        "lelah": SymptomInfo(medical: "Fatigue", category: .general, icdHint: "R53.83"),
        "capek": SymptomInfo(medical: "Fatigue", category: .general, icdHint: "R53.83"),
        "tidak nafsu makan": SymptomInfo(medical: "Anorexia", category: .general, icdHint: "R63.0"),
        "berat badan turun": SymptomInfo(medical: "Weight loss", category: .general, icdHint: "R63.4"),
        "keringat malam": SymptomInfo(medical: "Night sweats", category: .general, icdHint: "R61"),
        "pusing": SymptomInfo(medical: "Dizziness", category: .neurological, icdHint: "R42"),
        
        // Gejala Respiratori
        "batuk": SymptomInfo(medical: "Cough", category: .respiratory, icdHint: "R05.9"),
        "batuk berdahak": SymptomInfo(medical: "Productive cough", category: .respiratory, icdHint: "R05.09"),
        "batuk kering": SymptomInfo(medical: "Dry cough", category: .respiratory, icdHint: "R05.9"),
        "batuk darah": SymptomInfo(medical: "Hemoptysis", category: .respiratory, icdHint: "R04.2"),
        "sesak napas": SymptomInfo(medical: "Dyspnea", category: .respiratory, icdHint: "R06.00"),
        "sesak": SymptomInfo(medical: "Dyspnea", category: .respiratory, icdHint: "R06.00"),
        "pilek": SymptomInfo(medical: "Rhinorrhea", category: .respiratory, icdHint: "J00"),
        "hidung tersumbat": SymptomInfo(medical: "Nasal congestion", category: .respiratory, icdHint: "R09.81"),
        "sakit tenggorokan": SymptomInfo(medical: "Sore throat", category: .respiratory, icdHint: "J02.9"),
        "nyeri tenggorokan": SymptomInfo(medical: "Pharyngalgia", category: .respiratory, icdHint: "J02.9"),
        "bersin": SymptomInfo(medical: "Sneezing", category: .respiratory, icdHint: "R06.7"),
        "napas bunyi": SymptomInfo(medical: "Wheezing", category: .respiratory, icdHint: "R06.2"),
        "mengi": SymptomInfo(medical: "Wheezing", category: .respiratory, icdHint: "R06.2"),
        
        // Gejala Gastrointestinal
        "mual": SymptomInfo(medical: "Nausea", category: .gastrointestinal, icdHint: "R11.0"),
        "muntah": SymptomInfo(medical: "Vomiting", category: .gastrointestinal, icdHint: "R11.10"),
        "diare": SymptomInfo(medical: "Diarrhea", category: .gastrointestinal, icdHint: "R19.7"),
        "mencret": SymptomInfo(medical: "Diarrhea", category: .gastrointestinal, icdHint: "R19.7"),
        "sakit perut": SymptomInfo(medical: "Abdominal pain", category: .gastrointestinal, icdHint: "R10.9"),
        "nyeri perut": SymptomInfo(medical: "Abdominal pain", category: .gastrointestinal, icdHint: "R10.9"),
        "kembung": SymptomInfo(medical: "Bloating", category: .gastrointestinal, icdHint: "R14.0"),
        "sembelit": SymptomInfo(medical: "Constipation", category: .gastrointestinal, icdHint: "K59.00"),
        "susah bab": SymptomInfo(medical: "Constipation", category: .gastrointestinal, icdHint: "K59.00"),
        "bab berdarah": SymptomInfo(medical: "Hematochezia", category: .gastrointestinal, icdHint: "K92.1"),
        "maag": SymptomInfo(medical: "Dyspepsia", category: .gastrointestinal, icdHint: "K30"),
        "perih ulu hati": SymptomInfo(medical: "Epigastric pain", category: .gastrointestinal, icdHint: "K30"),
        "heartburn": SymptomInfo(medical: "GERD", category: .gastrointestinal, icdHint: "K21.0"),
        
        // Gejala Kardiovaskular
        "nyeri dada": SymptomInfo(medical: "Chest pain", category: .cardiovascular, icdHint: "R07.9"),
        "sakit dada": SymptomInfo(medical: "Chest pain", category: .cardiovascular, icdHint: "R07.9"),
        "dada terasa berat": SymptomInfo(medical: "Chest heaviness", category: .cardiovascular, icdHint: "R07.9"),
        "jantung berdebar": SymptomInfo(medical: "Palpitations", category: .cardiovascular, icdHint: "R00.2"),
        "berdebar": SymptomInfo(medical: "Palpitations", category: .cardiovascular, icdHint: "R00.2"),
        "bengkak kaki": SymptomInfo(medical: "Pedal edema", category: .cardiovascular, icdHint: "R60.0"),
        "keringat dingin": SymptomInfo(medical: "Cold sweats/Diaphoresis", category: .cardiovascular, icdHint: "R61"),
        
        // Gejala Neurologis
        "sakit kepala": SymptomInfo(medical: "Headache", category: .neurological, icdHint: "R51.9"),
        "nyeri kepala": SymptomInfo(medical: "Headache", category: .neurological, icdHint: "R51.9"),
        "kejang": SymptomInfo(medical: "Seizure", category: .neurological, icdHint: "R56.9"),
        "pingsan": SymptomInfo(medical: "Syncope", category: .neurological, icdHint: "R55"),
        "kesemutan": SymptomInfo(medical: "Paresthesia", category: .neurological, icdHint: "R20.2"),
        "kebas": SymptomInfo(medical: "Numbness", category: .neurological, icdHint: "R20.0"),
        "pandangan kabur": SymptomInfo(medical: "Blurred vision", category: .neurological, icdHint: "H53.8"),
        "bicara pelo": SymptomInfo(medical: "Dysarthria", category: .neurological, icdHint: "R47.1"),
        "lumpuh": SymptomInfo(medical: "Paralysis", category: .neurological, icdHint: "G83.9"),
        "lemah separuh badan": SymptomInfo(medical: "Hemiparesis", category: .neurological, icdHint: "G81.9"),
        
        // Gejala Muskuloskeletal
        "nyeri sendi": SymptomInfo(medical: "Arthralgia", category: .musculoskeletal, icdHint: "M25.50"),
        "nyeri otot": SymptomInfo(medical: "Myalgia", category: .musculoskeletal, icdHint: "M79.10"),
        "pegal": SymptomInfo(medical: "Myalgia", category: .musculoskeletal, icdHint: "M79.10"),
        "sakit pinggang": SymptomInfo(medical: "Low back pain", category: .musculoskeletal, icdHint: "M54.5"),
        "nyeri pinggang": SymptomInfo(medical: "Low back pain", category: .musculoskeletal, icdHint: "M54.5"),
        "bengkak sendi": SymptomInfo(medical: "Joint swelling", category: .musculoskeletal, icdHint: "M25.40"),
        
        // Gejala Kulit
        "gatal": SymptomInfo(medical: "Pruritus", category: .dermatological, icdHint: "L29.9"),
        "ruam": SymptomInfo(medical: "Rash", category: .dermatological, icdHint: "R21"),
        "bentol": SymptomInfo(medical: "Urticaria", category: .dermatological, icdHint: "L50.9"),
        "bisul": SymptomInfo(medical: "Abscess/Furuncle", category: .dermatological, icdHint: "L02.9"),
        "kuning": SymptomInfo(medical: "Jaundice", category: .dermatological, icdHint: "R17"),
        "luka": SymptomInfo(medical: "Wound", category: .dermatological, icdHint: "T14.1"),
        
        // Gejala Urogenital
        "nyeri kencing": SymptomInfo(medical: "Dysuria", category: .urogenital, icdHint: "R30.0"),
        "sering kencing": SymptomInfo(medical: "Frequency", category: .urogenital, icdHint: "R35.0"),
        "kencing darah": SymptomInfo(medical: "Hematuria", category: .urogenital, icdHint: "R31.9"),
        "keputihan": SymptomInfo(medical: "Vaginal discharge", category: .urogenital, icdHint: "N89.8"),
        
        // Gejala THT & Mata
        "sakit telinga": SymptomInfo(medical: "Otalgia", category: .entAndEye, icdHint: "H92.0"),
        "telinga berdenging": SymptomInfo(medical: "Tinnitus", category: .entAndEye, icdHint: "H93.1"),
        "mata merah": SymptomInfo(medical: "Conjunctivitis", category: .entAndEye, icdHint: "H10.9"),
        "mata gatal": SymptomInfo(medical: "Eye pruritus", category: .entAndEye, icdHint: "H10.9"),
    ]
    
    // MARK: - Red Flag Rules (Deterministic, NOT AI Guessing)
    
    /// Critical symptom combinations that require immediate attention
    static let redFlagRules: [RedFlagRule] = [
        RedFlagRule(
            name: "Acute Coronary Syndrome",
            triggerSymptoms: ["nyeri dada", "sesak napas", "keringat dingin"],
            minimumMatch: 2,
            urgency: .critical,
            action: "Rujuk IGD segera. Suspek Sindrom Koroner Akut. Berikan Aspirin 320mg kunyah jika tersedia."
        ),
        RedFlagRule(
            name: "Stroke",
            triggerSymptoms: ["lemah separuh badan", "bicara pelo", "pandangan kabur", "sakit kepala"],
            minimumMatch: 2,
            urgency: .critical,
            action: "Suspek Stroke. Catat onset gejala. Rujuk RS dengan fasilitas CT Scan segera. Golden period 4.5 jam."
        ),
        RedFlagRule(
            name: "Meningitis",
            triggerSymptoms: ["demam", "sakit kepala", "kejang", "penurunan kesadaran"],
            minimumMatch: 3,
            urgency: .critical,
            action: "Suspek Meningitis. Rujuk segera. Berikan antibiotik empiris jika rujukan jauh."
        ),
        RedFlagRule(
            name: "Severe Dehydration",
            triggerSymptoms: ["diare", "muntah", "lemas", "pusing"],
            minimumMatch: 3,
            urgency: .high,
            action: "Dehidrasi berat. Pasang infus RL/NaCl 0.9%. Monitor urine output."
        ),
        RedFlagRule(
            name: "Asthma Exacerbation",
            triggerSymptoms: ["sesak napas", "mengi", "batuk"],
            minimumMatch: 2,
            urgency: .high,
            action: "Eksaserbasi Asma. Nebulisasi Salbutamol 2.5mg. Monitor SpO2."
        ),
        RedFlagRule(
            name: "Dengue Warning Signs",
            triggerSymptoms: ["demam", "nyeri perut", "muntah", "lemas", "bab berdarah"],
            minimumMatch: 3,
            urgency: .high,
            action: "Suspek Dengue dengan warning signs. Cek trombosit & hematokrit. Pertimbangkan rawat inap."
        ),
        RedFlagRule(
            name: "Acute Abdomen",
            triggerSymptoms: ["nyeri perut", "muntah", "demam"],
            minimumMatch: 3,
            urgency: .high,
            action: "Suspek Akut Abdomen. Jangan berikan analgesik kuat sebelum evaluasi bedah. Rujuk."
        ),
        RedFlagRule(
            name: "Respiratory Distress",
            triggerSymptoms: ["sesak napas", "batuk darah", "demam"],
            minimumMatch: 2,
            urgency: .critical,
            action: "Distres Napas. Berikan O2. Suspek TB paru/pneumonia berat. Rontgen thorax segera."
        ),
        RedFlagRule(
            name: "Anaphylaxis",
            triggerSymptoms: ["sesak napas", "bentol", "bengkak", "pusing"],
            minimumMatch: 3,
            urgency: .critical,
            action: "Suspek Anafilaksis. Epinefrin 0.3mg IM (paha lateral). Posisi Trendelenburg."
        ),
        RedFlagRule(
            name: "Hypertensive Crisis",
            triggerSymptoms: ["sakit kepala", "pandangan kabur", "nyeri dada", "pusing"],
            minimumMatch: 3,
            urgency: .high,
            action: "Suspek Krisis Hipertensi. Ukur TD segera. Target penurunan TD 25% dalam 1 jam pertama."
        ),
    ]
    
    // MARK: - Common Diagnoses for Puskesmas (PPK Grounded)
    
    /// Top diagnoses seen at Puskesmas with PPK-grounded management
    static let commonDiagnoses: [DiagnosisEntry] = [
        DiagnosisEntry(
            name: "ISPA (Infeksi Saluran Pernapasan Akut)",
            icdCode: "J06.9",
            commonSymptoms: ["batuk", "pilek", "demam", "sakit tenggorokan"],
            management: "Simtomatik: Parasetamol 500mg 3x1, Ambroxol 30mg 3x1 jika batuk berdahak. Antibiotik hanya jika suspek bakteri.",
            fornasMedications: ["Parasetamol", "Ambroxol", "CTM", "Amoxicillin"]
        ),
        DiagnosisEntry(
            name: "Gastritis/Dyspepsia",
            icdCode: "K30",
            commonSymptoms: ["nyeri perut", "mual", "kembung", "perih ulu hati"],
            management: "Antasida 3x1 ac, Omeprazole 20mg 1x1 ac pagi. Edukasi pola makan.",
            fornasMedications: ["Antasida DOEN", "Omeprazole", "Ranitidine", "Sucralfate"]
        ),
        DiagnosisEntry(
            name: "Hipertensi Esensial",
            icdCode: "I10",
            commonSymptoms: ["sakit kepala", "pusing", "pandangan kabur"],
            management: "Amlodipine 5-10mg 1x1. Target TD <140/90. Edukasi diet rendah garam, olahraga.",
            fornasMedications: ["Amlodipine", "Captopril", "HCT", "Bisoprolol"]
        ),
        DiagnosisEntry(
            name: "Diabetes Mellitus Tipe 2",
            icdCode: "E11.9",
            commonSymptoms: ["sering kencing", "lemas", "berat badan turun", "pandangan kabur"],
            management: "Metformin 500mg 2x1 pc. Target GDP <126, GD2PP <200, HbA1c <7%. Edukasi diet & exercise.",
            fornasMedications: ["Metformin", "Glibenclamide", "Insulin NPH"]
        ),
        DiagnosisEntry(
            name: "Diare Akut",
            icdCode: "A09",
            commonSymptoms: ["diare", "mencret", "nyeri perut", "mual"],
            management: "Rehidrasi oral (oralit). Zinc 20mg 1x1 (anak). Antibiotik hanya jika diare berdarah/kolera.",
            fornasMedications: ["Oralit", "Zinc", "Loperamide", "Cotrimoxazole"]
        ),
        DiagnosisEntry(
            name: "Demam Dengue",
            icdCode: "A90",
            commonSymptoms: ["demam", "nyeri otot", "sakit kepala", "nyeri sendi", "ruam"],
            management: "Parasetamol 500mg 3x1 (JANGAN NSAID). Rehidrasi oral 2-3L/hari. Monitor trombosit tiap hari.",
            fornasMedications: ["Parasetamol", "Oralit"]
        ),
        DiagnosisEntry(
            name: "Asma Bronkial",
            icdCode: "J45.9",
            commonSymptoms: ["sesak napas", "mengi", "batuk", "dada terasa berat"],
            management: "Salbutamol inhaler 2 puff PRN. Jika persisten: Budesonide inhaler 200mcg 2x1.",
            fornasMedications: ["Salbutamol inhaler", "Budesonide inhaler", "Aminofilin"]
        ),
        DiagnosisEntry(
            name: "Infeksi Saluran Kemih",
            icdCode: "N39.0",
            commonSymptoms: ["nyeri kencing", "sering kencing", "demam"],
            management: "Cotrimoxazole 960mg 2x1 (3 hari wanita, 7 hari pria). Banyak minum air.",
            fornasMedications: ["Cotrimoxazole", "Ciprofloxacin", "Nitrofurantoin"]
        ),
        DiagnosisEntry(
            name: "Dermatitis/Alergi Kulit",
            icdCode: "L30.9",
            commonSymptoms: ["gatal", "ruam", "bentol"],
            management: "CTM 4mg 3x1 atau Cetirizine 10mg 1x1. Krim Hidrokortison 1% 2x1 topikal.",
            fornasMedications: ["CTM", "Cetirizine", "Hidrokortison krim", "Betamethasone krim"]
        ),
        DiagnosisEntry(
            name: "Low Back Pain (Nyeri Punggung Bawah)",
            icdCode: "M54.5",
            commonSymptoms: ["sakit pinggang", "nyeri pinggang", "pegal"],
            management: "Parasetamol 500mg 3x1 atau Ibuprofen 400mg 3x1 pc. Edukasi postur & peregangan.",
            fornasMedications: ["Parasetamol", "Ibuprofen", "Diclofenac", "Meloxicam"]
        ),
    ]
    
    // MARK: - Duration Keywords
    
    static let durationKeywords: [String] = [
        "hari", "minggu", "bulan", "tahun", "jam",
        "sejak", "sudah", "mulai", "tadi", "kemarin",
        "seminggu", "sebulan", "setahun",
        "tiga hari", "dua hari", "lima hari", "semalam",
        "pagi", "sore", "malam", "subuh",
    ]
    
    // MARK: - Medication Keywords
    
    static let medicationKeywords: [String] = [
        "paracetamol", "parasetamol", "amoxicillin", "amoksisilin",
        "ibuprofen", "antasida", "omeprazole", "amlodipine",
        "metformin", "ctm", "cetirizine", "salbutamol",
        "oralit", "obat", "minum obat", "tablet", "sirup",
        "kapsul", "puyer", "jamu", "herbal", "warung",
        "apotek", "resep", "antibiotik", "vitamin",
    ]
    
    // MARK: - Body Part Keywords
    
    static let bodyPartKeywords: [String] = [
        "kepala", "mata", "telinga", "hidung", "mulut",
        "tenggorokan", "leher", "dada", "perut", "pinggang",
        "punggung", "tangan", "kaki", "sendi", "lutut",
        "jari", "kulit", "gigi", "lidah", "ulu hati",
        "selangkangan", "bokong", "pundak", "bahu",
    ]
}

// MARK: - Supporting Types

struct SymptomInfo {
    let medical: String
    let category: SymptomCategory
    let icdHint: String
    
    enum SymptomCategory: String {
        case general = "Umum"
        case respiratory = "Respiratori"
        case gastrointestinal = "Gastrointestinal"
        case cardiovascular = "Kardiovaskular"
        case neurological = "Neurologis"
        case musculoskeletal = "Muskuloskeletal"
        case dermatological = "Dermatologis"
        case urogenital = "Urogenital"
        case entAndEye = "THT & Mata"
    }
}

struct RedFlagRule {
    let name: String
    let triggerSymptoms: [String]
    let minimumMatch: Int
    let urgency: RedFlag.UrgencyLevel
    let action: String
}

struct DiagnosisEntry {
    let name: String
    let icdCode: String
    let commonSymptoms: [String]
    let management: String
    let fornasMedications: [String]
}
