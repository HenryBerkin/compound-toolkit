import Foundation

enum ContributionFrequency: String, Codable, CaseIterable, Identifiable, Sendable {
    case weekly
    case monthly
    case annual

    var id: Self { self }

    var title: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .annual: "Annual"
        }
    }
}

enum CompoundFrequency: String, Codable, CaseIterable, Identifiable, Sendable {
    case daily
    case monthly
    case quarterly
    case annual

    var id: Self { self }

    var title: String {
        switch self {
        case .daily: "Daily"
        case .monthly: "Monthly"
        case .quarterly: "Quarterly"
        case .annual: "Annual"
        }
    }
}

enum ContributionTiming: String, Codable, CaseIterable, Identifiable, Sendable {
    case start
    case end

    var id: Self { self }

    var title: String {
        switch self {
        case .start: "Start of period"
        case .end: "End of period"
        }
    }
}

enum Currency: String, Codable, Sendable {
    case GBP
}

enum PresetID: String, Codable, CaseIterable, Identifiable, Sendable {
    case globalIndexDIY = "global-index-diy"
    case balancedPortfolio = "balanced-portfolio"
    case equityHeavyPortfolio = "equity-heavy-portfolio"
    case savingsAccount = "savings-account"

    var id: Self { self }
}

struct CalculationCandidate: Codable, Equatable, Sendable {
    var principal: Double
    var contribution: Double
    var contributionFrequency: ContributionFrequency
    var apr: Double
    var inflationRate: Double
    var annualFeeRate: Double
    var compoundFrequency: CompoundFrequency
    var years: Double
    var months: Double
    var timing: ContributionTiming
}

struct CalculationInput: Codable, Equatable, Sendable {
    var principal: Double
    var contribution: Double
    var contributionFrequency: ContributionFrequency
    var apr: Double
    var inflationRate: Double
    var annualFeeRate: Double
    var compoundFrequency: CompoundFrequency
    var years: Int
    var months: Int
    var timing: ContributionTiming

    var totalMonths: Int { years * 12 + months }
    var currency: Currency { .GBP }

    var candidate: CalculationCandidate {
        CalculationCandidate(
            principal: principal,
            contribution: contribution,
            contributionFrequency: contributionFrequency,
            apr: apr,
            inflationRate: inflationRate,
            annualFeeRate: annualFeeRate,
            compoundFrequency: compoundFrequency,
            years: Double(years),
            months: Double(months),
            timing: timing
        )
    }
}

struct MonthlyCalculationRow: Equatable, Sendable {
    let period: Int
    let year: Int
    let month: Int
    let startingBalance: Double
    let contributions: Double
    let interest: Double
    let endingBalance: Double
    let cumulativeContributions: Double
    let cumulativeInterest: Double
    let startingBalanceAfterFees: Double
    let feePaid: Double
    let cumulativeFeesPaid: Double
    let endingBalanceAfterFees: Double
}

struct AnnualCalculationRow: Equatable, Identifiable, Sendable {
    var id: Int { year }

    let year: Int
    let periodCount: Int
    let endPeriod: Int
    let startingBalance: Double
    let startingBalanceAfterFees: Double
    let contributions: Double
    let interest: Double
    let endingBalance: Double
    let cumulativeContributions: Double
    let cumulativeInterest: Double
    let yearlyFeesPaid: Double
    let cumulativeFeesPaid: Double
    let endingBalanceAfterFees: Double
    let realEndingBalance: Double
    let realEndingBalanceAfterFees: Double
    let realCumulativeContributions: Double
    let realCumulativeInterest: Double

    var isPartial: Bool { periodCount < 12 }
}

struct CalculationResult: Equatable, Sendable {
    let finalBalance: Double
    let totalContributions: Double
    let totalInterest: Double
    let totalFeesPaidNominal: Double
    let finalBalanceAfterFees: Double
    let finalBalanceReal: Double
    let totalContributionsReal: Double
    let totalInterestReal: Double
    let totalFeesPaidReal: Double
    let finalBalanceAfterFeesReal: Double
    let effectiveMonthlyRate: Double
    let effectiveMonthlyFeeRate: Double
    let effectiveMonthlyContribution: Double
    let monthlyRows: [MonthlyCalculationRow]
    let annualRows: [AnnualCalculationRow]
}
