import Foundation

struct ProjectionPreset: Equatable, Identifiable, Sendable {
    let id: PresetID
    let name: String
    let apr: Double
    let inflationRate: Double
    let annualFeeRate: Double
    let compoundFrequency: CompoundFrequency

    func matches(_ candidate: CalculationCandidate) -> Bool {
        candidate.apr == apr
            && candidate.inflationRate == inflationRate
            && candidate.annualFeeRate == annualFeeRate
            && candidate.compoundFrequency == compoundFrequency
    }

    func applying(to candidate: CalculationCandidate) -> CalculationCandidate {
        var updated = candidate
        updated.apr = apr
        updated.inflationRate = inflationRate
        updated.annualFeeRate = annualFeeRate
        updated.compoundFrequency = compoundFrequency
        return updated
    }
}
enum PresetCatalog {
    static let all: [ProjectionPreset] = [
        .init(
            id: .globalIndexDIY,
            name: "Global Index (DIY)",
            apr: 0.07,
            inflationRate: 0.03,
            annualFeeRate: 0.004,
            compoundFrequency: .monthly
        ),
        .init(
            id: .balancedPortfolio,
            name: "Balanced portfolio",
            apr: 0.06,
            inflationRate: 0.03,
            annualFeeRate: 0.0075,
            compoundFrequency: .monthly
        ),
        .init(
            id: .equityHeavyPortfolio,
            name: "Equity-heavy portfolio",
            apr: 0.09,
            inflationRate: 0.03,
            annualFeeRate: 0.01,
            compoundFrequency: .monthly
        ),
        .init(
            id: .savingsAccount,
            name: "Savings account",
            apr: 0.04,
            inflationRate: 0.03,
            annualFeeRate: 0,
            compoundFrequency: .monthly
        ),
    ]

    static let customBaseline = CalculationInput(
        principal: 10_000,
        contribution: 250,
        contributionFrequency: .monthly,
        apr: 0.07,
        inflationRate: 0.03,
        annualFeeRate: 0.002,
        compoundFrequency: .monthly,
        years: 15,
        months: 0,
        timing: .start
    )

    static func preset(_ id: PresetID) -> ProjectionPreset {
        all.first(where: { $0.id == id })!
    }

    static func truthfulSelection(
        persisted id: PresetID?,
        candidate: CalculationCandidate
    ) -> PresetID? {
        guard let id else { return nil }
        return preset(id).matches(candidate) ? id : nil
    }
}
