import Foundation

enum ValidationField: String, Codable, CaseIterable, Sendable {
    case principal
    case contribution
    case apr
    case inflationPercent
    case annualFeePercent
    case years
    case months
    case duration
}
struct ValidationIssue: Equatable, Sendable {
    let field: ValidationField
    let message: String
}

struct CalculationValidationResult: Equatable, Sendable {
    let input: CalculationInput?
    let issues: [ValidationIssue]

    var isValid: Bool { input != nil && issues.isEmpty }
    var errorFields: [ValidationField] { issues.map(\.field) }
}

enum CalculationValidator {
    static func validate(_ candidate: CalculationCandidate) -> CalculationValidationResult {
        var issues: [ValidationIssue] = []

        if !candidate.principal.isFinite || !(0...1_000_000_000).contains(candidate.principal) {
            issues.append(.init(
                field: .principal,
                message: "Enter a starting balance from £0 to £1,000,000,000."
            ))
        }
        if !candidate.contribution.isFinite || !(0...1_000_000_000).contains(candidate.contribution) {
            issues.append(.init(
                field: .contribution,
                message: "Enter a regular contribution from £0 to £1,000,000,000."
            ))
        }
        if !issues.contains(where: { $0.field == .principal || $0.field == .contribution }),
           candidate.principal == 0,
           candidate.contribution == 0 {
            issues.append(.init(
                field: .principal,
                message: "Starting balance and regular contribution can’t both be £0."
            ))
        }
        if !candidate.apr.isFinite || !(0...9.99).contains(candidate.apr) {
            issues.append(.init(
                field: .apr,
                message: "Enter an annual growth rate from 0% to 999%."
            ))
        }
        if !candidate.inflationRate.isFinite || !(0...0.20).contains(candidate.inflationRate) {
            issues.append(.init(
                field: .inflationPercent,
                message: "Enter inflation from 0% to 20%."
            ))
        }
        if !candidate.annualFeeRate.isFinite || !(0...0.10).contains(candidate.annualFeeRate) {
            issues.append(.init(
                field: .annualFeePercent,
                message: "Enter an annual fee from 0% to 10%."
            ))
        }

        let yearsIsInteger = candidate.years.isFinite && candidate.years.rounded(.towardZero) == candidate.years
        if !yearsIsInteger || candidate.years < 0 {
            issues.append(.init(field: .years, message: "Enter a whole number of years from 0 to 60."))
        }

        let monthsIsInteger = candidate.months.isFinite && candidate.months.rounded(.towardZero) == candidate.months
        if !monthsIsInteger || !(0...11).contains(candidate.months) {
            issues.append(.init(field: .months, message: "Extra months must be from 0 to 11."))
        }

        if yearsIsInteger, candidate.years >= 0, monthsIsInteger, (0...11).contains(candidate.months) {
            let duration = candidate.years * 12 + candidate.months
            if !(1...720).contains(duration) {
                issues.append(.init(field: .duration, message: "Enter a duration from 1 month to 60 years."))
            }
        }

        guard issues.isEmpty else {
            return CalculationValidationResult(input: nil, issues: issues)
        }

        return CalculationValidationResult(
            input: CalculationInput(
                principal: candidate.principal,
                contribution: candidate.contribution,
                contributionFrequency: candidate.contributionFrequency,
                apr: candidate.apr,
                inflationRate: candidate.inflationRate,
                annualFeeRate: candidate.annualFeeRate,
                compoundFrequency: candidate.compoundFrequency,
                years: Int(candidate.years),
                months: Int(candidate.months),
                timing: candidate.timing
            ),
            issues: []
        )
    }
}
