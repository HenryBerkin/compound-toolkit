import Foundation

enum TargetStatus: String, Equatable, Sendable {
    case above
    case below
    case equal
}
struct TargetAnalysis: Equatable, Sendable {
    let targetToday: Double
    let nominalTargetAtHorizon: Double
    let rawGap: Double
    let status: TargetStatus
}

enum TargetAnalyzer {
    static func analyze(
        targetToday: Double?,
        input: CalculationInput,
        result: CalculationResult
    ) -> TargetAnalysis? {
        guard let targetToday, targetToday.isFinite, targetToday >= 0 else { return nil }
        let factor = pow(
            1 + input.inflationRate,
            Double(input.totalMonths) / 12
        )
        let rawGap = result.finalBalanceAfterFeesReal - targetToday
        let status: TargetStatus = if rawGap > 0 {
            .above
        } else if rawGap < 0 {
            .below
        } else {
            .equal
        }
        return TargetAnalysis(
            targetToday: targetToday,
            nominalTargetAtHorizon: targetToday * factor,
            rawGap: rawGap,
            status: status
        )
    }
}
