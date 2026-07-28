import Foundation

enum CalculatorField: String, CaseIterable, Hashable {
    case principal
    case contribution
    case apr
    case inflation
    case fee
    case years
    case months
    case target
}
struct CalculatorDraft: Equatable {
    var principal = "10000"
    var contribution = "250"
    var contributionFrequency: ContributionFrequency = .monthly
    var apr = "7"
    var inflation = "3"
    var fee = "0.20"
    var compoundFrequency: CompoundFrequency = .monthly
    var years = "15"
    var months = "0"
    var timing: ContributionTiming = .start
    var target = ""
    var targetIsExpanded = false
    var presetID: PresetID?

    static let customBaseline = CalculatorDraft()

    mutating func selectPreset(_ id: PresetID?) {
        presetID = id
        guard let id else { return }
        let preset = PresetCatalog.preset(id)
        apr = inputText(preset.apr * 100)
        inflation = inputText(preset.inflationRate * 100)
        fee = inputText(preset.annualFeeRate * 100)
        compoundFrequency = preset.compoundFrequency
    }

    mutating func reconcilePreset() {
        guard let presetID,
              let candidate = parsed().candidate,
              PresetCatalog.preset(presetID).matches(candidate) else {
            presetID = nil
            return
        }
    }

    func parsed() -> ParsedCalculatorDraft {
        var errors: [CalculatorField: String] = [:]

        let principalValue = parseMoney(
            principal,
            field: .principal,
            message: "Enter a starting balance from £0 to £1,000,000,000.",
            errors: &errors
        )
        let contributionValue = parseMoney(
            contribution,
            field: .contribution,
            message: "Enter a regular contribution from £0 to £1,000,000,000.",
            errors: &errors
        )
        let aprValue = parseNumber(
            apr,
            allowBlank: false,
            field: .apr,
            message: "Enter an annual growth rate from 0% to 999%.",
            errors: &errors
        ).map { $0 / 100 }
        let inflationValue = parseNumber(
            inflation,
            allowBlank: true,
            field: .inflation,
            message: "Enter inflation from 0% to 20%.",
            errors: &errors
        ).map { $0 / 100 }
        let feeValue = parseNumber(
            fee,
            allowBlank: true,
            field: .fee,
            message: "Enter an annual fee from 0% to 10%.",
            errors: &errors
        ).map { $0 / 100 }
        let yearsValue = parseNumber(
            years,
            allowBlank: false,
            field: .years,
            message: "Enter a whole number of years from 0 to 60.",
            errors: &errors
        )
        let monthsValue = parseNumber(
            months,
            allowBlank: false,
            field: .months,
            message: "Extra months must be from 0 to 11.",
            errors: &errors
        )

        let targetValue: Double?
        if target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            targetValue = nil
        } else {
            targetValue = parseMoney(
                target,
                field: .target,
                message: "Enter a target of £0 or more, or remove the target.",
                errors: &errors
            )
        }

        guard errors.isEmpty,
              let principalValue,
              let contributionValue,
              let aprValue,
              let inflationValue,
              let feeValue,
              let yearsValue,
              let monthsValue else {
            return ParsedCalculatorDraft(candidate: nil, targetToday: targetValue, errors: errors)
        }

        return ParsedCalculatorDraft(
            candidate: CalculationCandidate(
                principal: principalValue,
                contribution: contributionValue,
                contributionFrequency: contributionFrequency,
                apr: aprValue,
                inflationRate: inflationValue,
                annualFeeRate: feeValue,
                compoundFrequency: compoundFrequency,
                years: yearsValue,
                months: monthsValue,
                timing: timing
            ),
            targetToday: targetValue,
            errors: errors
        )
    }

    private func parseMoney(
        _ text: String,
        field: CalculatorField,
        message: String,
        errors: inout [CalculatorField: String]
    ) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        return parse(cleaned, allowBlank: false, field: field, message: message, errors: &errors)
    }

    private func parseNumber(
        _ text: String,
        allowBlank: Bool,
        field: CalculatorField,
        message: String,
        errors: inout [CalculatorField: String]
    ) -> Double? {
        if text.contains("%") {
            errors[field] = message
            return nil
        }
        return parse(text, allowBlank: allowBlank, field: field, message: message, errors: &errors)
    }

    private func parse(
        _ text: String,
        allowBlank: Bool,
        field: CalculatorField,
        message: String,
        errors: inout [CalculatorField: String]
    ) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty, allowBlank { return 0 }
        guard !trimmed.isEmpty,
              !trimmed.localizedCaseInsensitiveContains("nan"),
              !trimmed.localizedCaseInsensitiveContains("inf"),
              !trimmed.contains("e"),
              !trimmed.contains("E"),
              let value = Double(trimmed),
              value.isFinite else {
            errors[field] = message
            return nil
        }
        return value
    }

    private func inputText(_ value: Double) -> String {
        var text = String(format: "%.4f", locale: Locale(identifier: "en_US_POSIX"), value)
        while text.last == "0" { text.removeLast() }
        if text.last == "." { text.removeLast() }
        return text
    }
}

struct ParsedCalculatorDraft {
    let candidate: CalculationCandidate?
    let targetToday: Double?
    let errors: [CalculatorField: String]
}
