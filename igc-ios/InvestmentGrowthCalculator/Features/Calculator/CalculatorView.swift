import SwiftUI
import UIKit

struct CalculatorView: View {
    @Binding var draft: CalculatorDraft
    let onProjection: (ProjectionSnapshot) -> Void

    @State private var errors: [CalculatorField: String] = [:]
    @State private var calculationError: String?
    @FocusState private var focusedField: CalculatorField?

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
                        errorLabel(error)
                    }
                    Picker("Contribution timing", selection: $draft.timing) {
                        ForEach(ContributionTiming.allCases) { timing in
                            Text(timing.title).tag(timing)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("calculator.timing")
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
                                draft.target = ""
                                errors[.target] = nil
                            }
                            .frame(minHeight: 44)
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
                    Button("Next") { moveFocus(by: 1) }
                        .disabled(nextField == nil)
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .onChange(of: draft.apr) { draft.reconcilePreset() }
            .onChange(of: draft.inflation) { draft.reconcilePreset() }
            .onChange(of: draft.fee) { draft.reconcilePreset() }
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
                errorLabel(error)
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

    private func errorLabel(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.footnote)
            .foregroundStyle(.red)
            .accessibilityIdentifier("calculator.error")
    }

    private func submit(using proxy: ScrollViewProxy) {
        calculationError = nil
        let parsed = draft.parsed()
        var newErrors = parsed.errors

        if let target = parsed.targetToday, target < 0 {
            newErrors[.target] = "Enter a target of £0 or more, or remove the target."
        }

        var validatedInput: CalculationInput?
        if let candidate = parsed.candidate {
            let validation = CalculationValidator.validate(candidate)
            validatedInput = validation.input
            for issue in validation.issues {
                let field: CalculatorField = switch issue.field {
                case .principal: .principal
                case .contribution: .contribution
                case .apr: .apr
                case .inflationPercent: .inflation
                case .annualFeePercent: .fee
                case .years, .duration: .years
                case .months: .months
                }
                if newErrors[field] == nil {
                    newErrors[field] = issue.message
                }
            }
        }

        errors = newErrors
        guard newErrors.isEmpty, let input = validatedInput else {
            focusFirstError(using: proxy)
            return
        }

        draft.presetID = PresetCatalog.truthfulSelection(
            persisted: draft.presetID,
            candidate: input.candidate
        )
        do {
            let snapshot = try ProjectionSnapshot(
                input: input,
                presetID: draft.presetID,
                targetToday: parsed.targetToday
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
        withAnimation {
            proxy.scrollTo(first, anchor: .center)
        }
        focusedField = first
        let firstMessage = errors[first] ?? "Review the first field."
        UIAccessibility.post(
            notification: .announcement,
            argument: "Can’t view projection. \(errors.count) fields need attention. \(firstMessage)"
        )
    }
}
