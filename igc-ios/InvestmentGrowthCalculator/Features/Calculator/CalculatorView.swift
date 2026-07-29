import SwiftUI
import UIKit

struct CalculatorView: View {
    @Binding var draft: CalculatorDraft
    let loadedScenario: LoadedScenarioContext?
    let onProjection: (ProjectionSnapshot) -> Void

    @State private var errors: [CalculatorField: String] = [:]
    @State private var calculationError: String?
    @State private var showsRemoveTargetConfirmation = false
    @FocusState private var focusedField: CalculatorField?
    @AccessibilityFocusState private var loadedStatusFocused: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let fieldOrder: [CalculatorField] = [
        .principal, .contribution, .apr, .inflation, .fee, .years, .target,
    ]

    var body: some View {
        ScrollViewReader { proxy in
            Form {
                Section {
                    Text("Explore an illustrative projection using your assumptions.")
                        .foregroundStyle(.secondary)
                }
                .id("calculator.top")

                if let loadedScenario {
                    Section {
                        Text("Loaded “\(loadedScenario.name)”")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("calculator.loadedStatus")
                            .accessibilityFocused($loadedStatusFocused)
                        Text("Review the assumptions, then view the projection.")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Preset") {
                    Picker("Preset", selection: presetBinding) {
                        Text("Custom").tag(PresetID?.none)
                        ForEach(PresetCatalog.all) { preset in
                            Text(preset.name).tag(Optional(preset.id))
                        }
                    }
                    .accessibilityIdentifier("calculator.preset")
                    Text("Presets update growth, inflation, fee and compounding.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Investment") {
                    inputRow(
                        label: "Starting balance",
                        unit: "£",
                        text: $draft.principal,
                        field: .principal,
                        keyboard: .decimalPad,
                        identifier: "calculator.principal",
                        helper: "Amount invested now."
                    )
                    inputRow(
                        label: "Regular contribution",
                        unit: "£",
                        text: $draft.contribution,
                        field: .contribution,
                        keyboard: .decimalPad,
                        identifier: "calculator.contribution",
                        helper: "Amount added at the selected frequency."
                    )
                    Picker("Contribution frequency", selection: $draft.contributionFrequency) {
                        ForEach(ContributionFrequency.allCases) { frequency in
                            Text(frequency.title).tag(frequency)
                        }
                    }
                    .accessibilityIdentifier("calculator.contributionFrequency")
                    if draft.contributionFrequency == .weekly {
                        Text("The model converts this as amount × 52 ÷ 12 each month.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else if draft.contributionFrequency == .annual {
                        Text("The model spreads this as amount ÷ 12 each month.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Growth and costs") {
                    inputRow(
                        label: "Annual growth rate (APR)",
                        unit: "%",
                        text: $draft.apr,
                        field: .apr,
                        keyboard: .decimalPad,
                        identifier: "calculator.apr",
                        helper: "Assumed yearly growth before fees and inflation."
                    )
                    inputRow(
                        label: "Inflation",
                        unit: "%",
                        text: $draft.inflation,
                        field: .inflation,
                        keyboard: .decimalPad,
                        identifier: "calculator.inflation",
                        helper: "Used for today’s-money values. Blank means 0%."
                    )
                    inputRow(
                        label: "Annual fee",
                        unit: "%",
                        text: $draft.fee,
                        field: .fee,
                        keyboard: .decimalPad,
                        identifier: "calculator.fee",
                        helper: "Ongoing asset-based fee assumption. Blank means 0%."
                    )
                    Picker("Compounding", selection: $draft.compoundFrequency) {
                        ForEach(CompoundFrequency.allCases) { frequency in
                            Text(frequency.title).tag(frequency)
                        }
                    }
                    .accessibilityIdentifier("calculator.compounding")
                    .onChange(of: draft.compoundFrequency) {
                        draft.reconcilePreset()
                    }
                }

                Section("Duration and timing") {
                    inputRow(
                        label: "Years",
                        unit: nil,
                        text: $draft.years,
                        field: .years,
                        keyboard: .numberPad,
                        identifier: "calculator.years",
                        helper: nil
                    )
                    Picker("Extra months", selection: $draft.months) {
                        ForEach(0..<12, id: \.self) { month in
                            Text("\(month)").tag(String(month))
                        }
                    }
                    .accessibilityIdentifier("calculator.months")
                    if let error = errors[.months] {
                        errorLabel(error, field: .months)
                    }
                    contributionTimingPicker
                    Text(draft.timing == .start
                         ? "Each monthly-equivalent contribution is added before that month’s growth and fee."
                         : "Each monthly-equivalent contribution is added after that month’s growth and fee.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    DisclosureGroup(
                        "Target in today’s money (optional)",
                        isExpanded: $draft.targetIsExpanded
                    ) {
                        Text("Compare the after-fee projection with an amount in today’s purchasing power.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        inputRow(
                            label: "Target in today’s money (optional)",
                            unit: "£",
                            text: $draft.target,
                            field: .target,
                            keyboard: .decimalPad,
                            identifier: "calculator.target",
                            helper: "Blank means no target. Zero is a valid target."
                        )
                        if !draft.target.isEmpty {
                            Button("Remove target", role: .destructive) {
                                showsRemoveTargetConfirmation = true
                            }
                            .frame(minHeight: 44)
                            .accessibilityIdentifier("calculator.removeTarget")
                            .accessibilityHint(
                                "Current target \(currentTargetDescription). "
                                    + "Asks for confirmation before removing it."
                            )
                        }
                    }
                }

                if let calculationError {
                    Section {
                        Label(calculationError, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("calculator.calculationError")
                    }
                }

                Section {
                    Button("View projection") {
                        submit(using: proxy)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .accessibilityIdentifier("calculator.viewProjection")

                    Text("Illustrative projection based on your assumptions. It is not financial advice or a forecast.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Calculator")
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Previous") { moveFocus(by: -1) }
                        .disabled(previousField == nil)
                    Button("Next") { validateAndMoveToNextField() }
                        .disabled(nextField == nil)
                    Spacer()
                    Button("Done") { validateAndDismissKeyboard() }
                }
            }
            .alert(
                "Remove target?",
                isPresented: $showsRemoveTargetConfirmation,
            ) {
                Button("Remove target", role: .destructive) {
                    removeTarget()
                }
                .accessibilityIdentifier("calculator.confirmRemoveTarget")
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Discard the current target \(currentTargetDescription)?")
            }
            .onChange(of: draft.apr) { draft.reconcilePreset() }
            .onChange(of: draft.inflation) { draft.reconcilePreset() }
            .onChange(of: draft.fee) { draft.reconcilePreset() }
            .onChange(of: loadedScenario?.id) {
                Task { @MainActor in
                    await Task.yield()
                    proxy.scrollTo("calculator.top", anchor: .top)
                    loadedStatusFocused = true
                }
            }
            .onChange(of: focusedField) { oldField, newField in
                if let oldField, oldField != newField {
                    validateField(oldField)
                }
            }
        }
    }

    private var presetBinding: Binding<PresetID?> {
        Binding(
            get: { draft.presetID },
            set: { draft.selectPreset($0) }
        )
    }

    private var previousField: CalculatorField? {
        guard let focusedField,
              let index = activeFieldOrder.firstIndex(of: focusedField),
              index > 0 else { return nil }
        return activeFieldOrder[index - 1]
    }

    private var nextField: CalculatorField? {
        guard let focusedField,
              let index = activeFieldOrder.firstIndex(of: focusedField),
              index < activeFieldOrder.count - 1 else { return nil }
        return activeFieldOrder[index + 1]
    }

    private var activeFieldOrder: [CalculatorField] {
        fieldOrder.filter { $0 != .target || draft.targetIsExpanded }
    }

    @ViewBuilder
    private var contributionTimingPicker: some View {
        if dynamicTypeSize.isAccessibilitySize {
            timingMenu
        } else {
            ViewThatFits(in: .horizontal) {
                timingSegments
                    .fixedSize(horizontal: true, vertical: false)
                timingMenu
            }
        }
    }

    private var timingSegments: some View {
        Picker("Contribution timing", selection: $draft.timing) {
            ForEach(ContributionTiming.allCases) { timing in
                Text(timing.title).tag(timing)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("calculator.timing.segmented")
    }

    private var timingMenu: some View {
        Picker("Contribution timing", selection: $draft.timing) {
            ForEach(ContributionTiming.allCases) { timing in
                Text(timing.title).tag(timing)
            }
        }
        .pickerStyle(.menu)
        .accessibilityIdentifier("calculator.timing.menu")
    }

    private func moveFocus(by offset: Int) {
        guard let focusedField,
              let index = activeFieldOrder.firstIndex(of: focusedField) else { return }
        let nextIndex = index + offset
        guard activeFieldOrder.indices.contains(nextIndex) else { return }
        self.focusedField = activeFieldOrder[nextIndex]
    }

    @ViewBuilder
    private func inputRow(
        label: String,
        unit: String?,
        text: Binding<String>,
        field: CalculatorField,
        keyboard: UIKeyboardType,
        identifier: String,
        helper: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.body)
            HStack {
                if let unit {
                    Text(unit)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                TextField(label, text: text)
                    .keyboardType(keyboard)
                    .focused($focusedField, equals: field)
                    .accessibilityIdentifier(identifier)
                    .accessibilityValue(accessibilityValue(text.wrappedValue, unit: unit))
                    .onChange(of: text.wrappedValue) {
                        clearResolvedErrors(affectedBy: field)
                    }
                if unit == "%" {
                    Text("%")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            if let helper {
                Text(helper)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let error = errors[field] {
                errorLabel(error, field: field)
            }
        }
        .id(field)
    }

    private func accessibilityValue(_ text: String, unit: String?) -> String {
        switch unit {
        case "£": "\(text) pounds"
        case "%": "\(text) percent"
        default: text
        }
    }

    private func errorLabel(_ message: String, field: CalculatorField) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
            .accessibilityIdentifier("calculator.error.\(field.rawValue)")
    }

    private func submit(using proxy: ScrollViewProxy) {
        calculationError = nil
        let usesUntouchedLoadedValues = loadedScenario.map {
            draft.hasSameCanonicalDraftFields(as: $0.draftAtLoad)
        } ?? false
        let input: CalculationInput
        let targetToday: Double?

        if usesUntouchedLoadedValues, let loadedScenario {
            errors = [:]
            input = loadedScenario.input
            targetToday = loadedScenario.targetToday
        } else {
            let validation = draft.validation()
            errors = validation.errors
            guard validation.errors.isEmpty, let validatedInput = validation.input else {
                focusFirstError(using: proxy)
                return
            }
            input = validatedInput
            targetToday = validation.parsed.targetToday
        }

        draft.presetID = PresetCatalog.truthfulSelection(
            persisted: draft.presetID,
            candidate: input.candidate
        )
        do {
            let snapshot = try ProjectionSnapshot(
                input: input,
                presetID: draft.presetID,
                targetToday: targetToday,
                sourceScenarioID: loadedScenario?.id
            )
            focusedField = nil
            onProjection(snapshot)
        } catch {
            calculationError = "Projection unavailable. Review the assumptions and try again."
            UIAccessibility.post(
                notification: .announcement,
                argument: "Projection unavailable. Return to calculator."
            )
        }
    }

    private func focusFirstError(using proxy: ScrollViewProxy) {
        let first = CalculatorField.allCases.first(where: { errors[$0] != nil })
        guard let first else { return }
        if first == .target, !draft.targetIsExpanded {
            draft.targetIsExpanded = true
        }
        let firstMessage = errors[first] ?? "Review the first field."
        UIAccessibility.post(
            notification: .announcement,
            argument: "Can’t view projection. \(errors.count) fields need attention. \(firstMessage)"
        )
        Task { @MainActor in
            await Task.yield()
            withAnimation {
                proxy.scrollTo(first, anchor: .center)
            }
            focusedField = first
        }
    }

    private func validateAndMoveToNextField() {
        guard let current = focusedField else { return }
        validateField(current)
        moveFocus(by: 1)
    }

    private func validateAndDismissKeyboard() {
        if let focusedField {
            validateField(focusedField)
        }
        focusedField = nil
    }

    private func validateField(_ field: CalculatorField) {
        let validationErrors = draft.validation().errors
        for affectedField in fieldsAffected(by: field) {
            errors[affectedField] = validationErrors[affectedField]
        }
    }

    private func clearResolvedErrors(affectedBy field: CalculatorField) {
        guard focusedField == field else { return }
        let validationErrors = draft.validation().errors
        for affectedField in fieldsAffected(by: field)
        where errors[affectedField] != nil && validationErrors[affectedField] == nil {
            errors[affectedField] = nil
        }
    }

    private func fieldsAffected(by field: CalculatorField) -> [CalculatorField] {
        switch field {
        case .principal, .contribution:
            [.principal, .contribution]
        case .years, .months:
            [.years, .months]
        default:
            [field]
        }
    }

    private var currentTargetDescription: String {
        guard let value = CalculatorInputParser.money(draft.target) else {
            return "\(draft.target) pounds"
        }
        return IGCFormatters.gbp(value)
    }

    private func removeTarget() {
        draft.target = ""
        draft.targetIsExpanded = false
        errors[.target] = nil
        if focusedField == .target {
            focusedField = nil
        }
    }
}
