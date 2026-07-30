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
struct CalculatorDraft: Equatable, Sendable {
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

    init() {}

    init(scenario: ScenarioV1) {
        principal = Self.inputText(scenario.inputs.principal)
        contribution = Self.inputText(scenario.inputs.contribution)
        contributionFrequency = scenario.inputs.contributionFrequency
        apr = Self.inputText(scenario.inputs.apr * 100)
        inflation = Self.inputText(scenario.inputs.inflationRate * 100)
        fee = Self.inputText(scenario.inputs.annualFeeRate * 100)
        compoundFrequency = scenario.inputs.compoundFrequency
        years = String(scenario.inputs.years)
        months = String(scenario.inputs.months)
        timing = scenario.inputs.timing
        if let targetToday = scenario.targetToday {
            target = Self.inputText(targetToday)
            targetIsExpanded = true
        } else {
            target = ""
            targetIsExpanded = false
        }
        presetID = PresetCatalog.truthfulSelection(
            persisted: scenario.presetID,
            candidate: scenario.inputs.candidate
        )
    }

    mutating func selectPreset(_ id: PresetID?) {
        presetID = id
        guard let id else { return }
        let preset = PresetCatalog.preset(id)
        apr = Self.inputText(preset.apr * 100)
        inflation = Self.inputText(preset.inflationRate * 100)
        fee = Self.inputText(preset.annualFeeRate * 100)
        compoundFrequency = preset.compoundFrequency
    }

    mutating func reconcilePreset() {
        guard let presetID else { return }
        guard let aprValue = CalculatorInputParser.number(apr, allowBlank: false),
              let inflationValue = CalculatorInputParser.number(inflation, allowBlank: true),
              let feeValue = CalculatorInputParser.number(fee, allowBlank: true) else {
            self.presetID = nil
            return
        }

        var candidate = PresetCatalog.customBaseline.candidate
        candidate.apr = aprValue / 100
        candidate.inflationRate = inflationValue / 100
        candidate.annualFeeRate = feeValue / 100
        candidate.compoundFrequency = compoundFrequency
        if !PresetCatalog.preset(presetID).matches(candidate) {
            self.presetID = nil
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
        let yearsValue = parseWholeNumber(
            years,
            field: .years,
            message: "Enter a whole number of years.",
            errors: &errors
        )
        let monthsValue = parseWholeNumber(
            months,
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

    func validation() -> CalculatorDraftValidation {
        let parsed = parsed()
        var validationErrors = parsed.errors
        var validatedInput: CalculationInput?

        if let candidate = parsed.candidate {
            let canonicalValidation = CalculationValidator.validate(candidate)
            validatedInput = canonicalValidation.input
            for issue in canonicalValidation.issues {
                let field: CalculatorField = switch issue.field {
                case .principal: .principal
                case .contribution: .contribution
                case .apr: .apr
                case .inflationPercent: .inflation
                case .annualFeePercent: .fee
                case .years, .duration: .years
                case .months: .months
                }
                if validationErrors[field] == nil {
                    validationErrors[field] = issue.message
                }
            }
        }

        return CalculatorDraftValidation(
            parsed: parsed,
            input: validatedInput,
            errors: validationErrors
        )
    }

    private func parseMoney(
        _ text: String,
        field: CalculatorField,
        message: String,
        errors: inout [CalculatorField: String]
    ) -> Double? {
        guard let value = CalculatorInputParser.money(text) else {
            errors[field] = message
            return nil
        }
        return value
    }

    private func parseNumber(
        _ text: String,
        allowBlank: Bool,
        field: CalculatorField,
        message: String,
        errors: inout [CalculatorField: String]
    ) -> Double? {
        guard let value = CalculatorInputParser.number(text, allowBlank: allowBlank) else {
            errors[field] = message
            return nil
        }
        return value
    }

    private func parseWholeNumber(
        _ text: String,
        field: CalculatorField,
        message: String,
        errors: inout [CalculatorField: String]
    ) -> Double? {
        guard let value = CalculatorInputParser.wholeNumber(text) else {
            errors[field] = message
            return nil
        }
        return value
    }

    private static func inputText(_ value: Double) -> String {
        String(
            format: "%.15g",
            locale: Locale(identifier: "en_US_POSIX"),
            value
        )
    }

    func hasSameCanonicalDraftFields(as other: CalculatorDraft) -> Bool {
        var lhs = self
        var rhs = other
        lhs.targetIsExpanded = false
        rhs.targetIsExpanded = false
        return lhs == rhs
    }
}

struct ParsedCalculatorDraft {
    let candidate: CalculationCandidate?
    let targetToday: Double?
    let errors: [CalculatorField: String]
}

struct CalculatorDraftValidation {
    let parsed: ParsedCalculatorDraft
    let input: CalculationInput?
    let errors: [CalculatorField: String]
}

enum CalculatorInputParser {
    private static let groupingSpaces: Set<Character> = [" ", "\u{00A0}", "\u{202F}"]

    static func money(_ rawText: String) -> Double? {
        var text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        if text.first == "£" {
            text.removeFirst()
            text = text.trimmingCharacters(in: .whitespaces)
        }
        guard !text.isEmpty, !text.contains("£") else { return nil }

        let decimalParts = text.split(separator: ".", omittingEmptySubsequences: false)
        guard decimalParts.count <= 2,
              let integerPart = decimalParts.first,
              !integerPart.isEmpty else {
            return nil
        }
        if decimalParts.count == 2 {
            let fraction = decimalParts[1]
            guard !fraction.isEmpty, fraction.allSatisfy(isASCIIDigit) else { return nil }
        }

        guard let canonicalInteger = canonicalGroupedInteger(String(integerPart)) else {
            return nil
        }
        let canonical = decimalParts.count == 2
            ? "\(canonicalInteger).\(decimalParts[1])"
            : canonicalInteger
        return finiteDouble(canonical)
    }

    static func number(_ rawText: String, allowBlank: Bool) -> Double? {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty, allowBlank { return 0 }
        guard !text.isEmpty else { return nil }

        let parts = text.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count <= 2,
              let integerPart = parts.first,
              !integerPart.isEmpty,
              integerPart.allSatisfy(isASCIIDigit) else {
            return nil
        }
        if parts.count == 2 {
            let fraction = parts[1]
            guard !fraction.isEmpty, fraction.allSatisfy(isASCIIDigit) else { return nil }
        }
        return finiteDouble(text)
    }

    static func wholeNumber(_ rawText: String) -> Double? {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text.allSatisfy(isASCIIDigit) else { return nil }
        return finiteDouble(text)
    }

    private static func canonicalGroupedInteger(_ integer: String) -> String? {
        if integer.allSatisfy(isASCIIDigit) {
            return integer
        }

        let separators = Set(integer.filter { !isASCIIDigit($0) })
        guard separators.count == 1, let separator = separators.first,
              separator == "," || groupingSpaces.contains(separator) else {
            return nil
        }

        let groups = integer.split(separator: separator, omittingEmptySubsequences: false)
        guard groups.count >= 2,
              let first = groups.first,
              (1...3).contains(first.count),
              first.allSatisfy(isASCIIDigit),
              groups.dropFirst().allSatisfy({
                  $0.count == 3 && $0.allSatisfy(isASCIIDigit)
              }) else {
            return nil
        }
        return groups.joined()
    }

    private static func finiteDouble(_ canonical: String) -> Double? {
        guard let decimal = Decimal(
            string: canonical,
            locale: Locale(identifier: "en_GB")
        ) else {
            return nil
        }
        let value = NSDecimalNumber(decimal: decimal).doubleValue
        return value.isFinite ? value : nil
    }

    private static func isASCIIDigit(_ character: Character) -> Bool {
        character >= "0" && character <= "9"
    }
}
