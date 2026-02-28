import SwiftUI

// MARK: - SOAP Review View
// Review & edit the generated SOAP note after consultation
// "One Tap Done" — Minute 2:00–2:30 of the 3-minute experience

struct SOAPReviewView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var isEditing = false
    @State private var appeared = false
    @State private var savedAnimation = false
    
    // Editable copies
    @State private var editSubjective = ""
    @State private var editObjective = ""
    @State private var editAssessment = ""
    @State private var editPlan = ""
    
    var body: some View {
        ZStack {
            HadirTheme.cream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: HadirTheme.spacingLG) {
                    // Header
                    headerSection
                    
                    // SOAP Sections
                    soapSections
                    
                    // Diagnosis Suggestions
                    if !coordinator.soapGenerator.diagnosisSuggestions.isEmpty {
                        diagnosisSuggestionsSection
                    }
                    
                    // Red Flags Summary
                    if !coordinator.soapGenerator.detectedRedFlags.isEmpty {
                        redFlagsSummarySection
                    }
                    
                    // Consultation Info
                    consultationInfoSection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(HadirTheme.spacingLG)
            }
            
            // Save Animation Overlay
            if savedAnimation {
                saveAnimationOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            loadEditableFields()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: HadirTheme.spacingSM) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 36))
                .foregroundColor(HadirTheme.emerald)
            
            Text("SOAP Note")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(HadirTheme.textPrimary)
            
            Text("Dibuat otomatis dari percakapan konsultasi")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
            
            // Duration badge
            HStack(spacing: HadirTheme.spacingSM) {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                Text("Durasi: \(coordinator.formattedElapsedTime)")
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundColor(HadirTheme.emerald)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(HadirTheme.emeraldLight)
            .cornerRadius(12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("SOAP Note. Durasi konsultasi: \(coordinator.formattedElapsedTime)")
    }
    
    // MARK: - SOAP Sections
    
    private var soapSections: some View {
        VStack(spacing: HadirTheme.spacingMD) {
            editableSOAPSection(
                label: "S — Subjective",
                icon: "person.wave.2.fill",
                color: HadirTheme.patientColor,
                text: isEditing ? $editSubjective : .constant(coordinator.soapGenerator.currentNote.subjective.summary),
                placeholder: "Keluhan utama, riwayat penyakit sekarang, gejala penyerta..."
            )
            
            editableSOAPSection(
                label: "O — Objective",
                icon: "stethoscope",
                color: HadirTheme.doctorColor,
                text: isEditing ? $editObjective : .constant(coordinator.soapGenerator.currentNote.objective.summary),
                placeholder: "Tanda vital, pemeriksaan fisik..."
            )
            
            editableSOAPSection(
                label: "A — Assessment",
                icon: "brain.head.profile",
                color: HadirTheme.emerald,
                text: isEditing ? $editAssessment : .constant(coordinator.soapGenerator.currentNote.assessment.summary),
                placeholder: "Diagnosis utama, diagnosis banding..."
            )
            
            editableSOAPSection(
                label: "P — Plan",
                icon: "list.clipboard.fill",
                color: .purple,
                text: isEditing ? $editPlan : .constant(coordinator.soapGenerator.currentNote.plan.summary),
                placeholder: "Terapi, edukasi, rencana tindak lanjut..."
            )
        }
    }
    
    private func editableSOAPSection(label: String, icon: String, color: Color, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: HadirTheme.spacingSM) {
            HStack(spacing: HadirTheme.spacingSM) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            if isEditing {
                TextEditor(text: text)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(HadirTheme.textPrimary)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(text.wrappedValue.isEmpty ? HadirTheme.textSecondary : HadirTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(HadirTheme.spacingMD)
        .background(color.opacity(0.06))
        .cornerRadius(HadirTheme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: HadirTheme.radiusMD)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(text.wrappedValue.isEmpty ? "Belum terisi" : text.wrappedValue)")
    }
    
    // MARK: - Diagnosis Suggestions
    
    private var diagnosisSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: HadirTheme.spacingMD) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(HadirTheme.emerald)
                Text("Saran Diagnosis (PPK)")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(HadirTheme.textPrimary)
            }
            
            ForEach(coordinator.soapGenerator.diagnosisSuggestions.prefix(3)) { suggestion in
                diagnosisSuggestionRow(suggestion)
            }
        }
        .hadirCard()
    }
    
    private func diagnosisSuggestionRow(_ suggestion: DiagnosisSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(suggestion.name)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(HadirTheme.textPrimary)
                
                Spacer()
                
                Text("\(suggestion.confidencePercentage)%")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundColor(HadirTheme.emerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(HadirTheme.emeraldLight)
                    .cornerRadius(8)
            }
            
            Text("ICD-10: \(suggestion.icdCode)")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
            
            // Matched symptoms
            HStack(spacing: 4) {
                ForEach(suggestion.matchedSymptoms, id: \.self) { symptom in
                    Text(symptom)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(HadirTheme.emerald)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(HadirTheme.emeraldLight)
                        .cornerRadius(6)
                }
            }
            
            // Management
            Text(suggestion.management)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
                .lineLimit(3)
        }
        .padding(HadirTheme.spacingMD)
        .background(HadirTheme.cream)
        .cornerRadius(HadirTheme.radiusSM)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suggestion.name), kecocokan \(suggestion.confidencePercentage) persen. \(suggestion.management)")
    }
    
    // MARK: - Red Flags Summary
    
    private var redFlagsSummarySection: some View {
        VStack(alignment: .leading, spacing: HadirTheme.spacingMD) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(HadirTheme.terracotta)
                Text("Red Flags Terdeteksi")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(HadirTheme.terracotta)
            }
            
            ForEach(coordinator.soapGenerator.detectedRedFlags) { flag in
                VStack(alignment: .leading, spacing: 4) {
                    Text(flag.condition)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(HadirTheme.textPrimary)
                    
                    Text(flag.action)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(HadirTheme.textSecondary)
                }
                .padding(HadirTheme.spacingSM)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(HadirTheme.terracottaLight)
                .cornerRadius(HadirTheme.radiusSM)
            }
        }
        .hadirCard()
    }
    
    // MARK: - Consultation Info
    
    private var consultationInfoSection: some View {
        HStack(spacing: HadirTheme.spacingMD) {
            infoItem(icon: "clock.fill", label: "Durasi", value: coordinator.formattedElapsedTime)
            infoItem(icon: "text.alignleft", label: "Segmen", value: "\(coordinator.soapGenerator.currentNote.transcript.count)")
            infoItem(icon: "stethoscope", label: "Gejala", value: "\(coordinator.soapGenerator.allDetectedSymptoms.count)")
        }
    }
    
    private func infoItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(HadirTheme.emerald)
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(HadirTheme.textPrimary)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(HadirTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(HadirTheme.spacingMD)
        .background(HadirTheme.cardBackground)
        .cornerRadius(HadirTheme.radiusMD)
        .shadow(color: HadirTheme.shadowColor, radius: 4, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: HadirTheme.spacingMD) {
            // Edit toggle
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if isEditing {
                        saveEdits()
                    }
                    isEditing.toggle()
                }
            }) {
                HStack(spacing: HadirTheme.spacingSM) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                    Text(isEditing ? "Selesai Edit" : "Edit SOAP Note")
                }
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundColor(HadirTheme.emerald)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(HadirTheme.emeraldLight)
                .cornerRadius(HadirTheme.radiusXL)
            }
            .accessibilityLabel(isEditing ? "Selesai Edit" : "Edit SOAP Note")
            
            // Save button — the CTA
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    savedAnimation = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    coordinator.saveAndFinish()
                }
            }) {
                HStack(spacing: HadirTheme.spacingSM) {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Simpan ke Rekam Medis")
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(HadirTheme.emerald)
                .cornerRadius(HadirTheme.radiusXL)
                .shadow(color: HadirTheme.emerald.opacity(0.3), radius: 12, y: 6)
            }
            .accessibilityLabel("Simpan ke Rekam Medis")
            .accessibilityHint("Ketuk untuk menyimpan SOAP note dan melihat ringkasan")
        }
    }
    
    // MARK: - Save Animation Overlay
    
    private var saveAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: HadirTheme.spacingMD) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 64))
                    .foregroundColor(HadirTheme.emerald)
                    .symbolEffect(.bounce, options: .nonRepeating)
                
                Text("Tersimpan!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(HadirTheme.textPrimary)
            }
            .padding(HadirTheme.spacingXL)
            .background(HadirTheme.cream)
            .cornerRadius(HadirTheme.radiusXL)
            .shadow(color: HadirTheme.emerald.opacity(0.3), radius: 20)
        }
    }
    
    // MARK: - Helpers
    
    private func loadEditableFields() {
        let note = coordinator.soapGenerator.currentNote
        editSubjective = note.subjective.summary
        editObjective = note.objective.summary
        editAssessment = note.assessment.summary
        editPlan = note.plan.summary
    }
    
    private func saveEdits() {
        // In a full app, you'd parse these back into structured data
        // For the SSC demo, we keep the text edits
    }
}
