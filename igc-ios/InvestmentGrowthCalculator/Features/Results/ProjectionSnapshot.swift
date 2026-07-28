import Foundation

struct ProjectionSnapshot: Identifiable, Equatable, Sendable {
    let id: UUID
    let input: CalculationInput
    let presetID: PresetID?
    let targetToday: Double?
    let result: CalculationResult
    let targetAnalysis: TargetAnalysis?

    init(
        input: CalculationInput,
        presetID: PresetID?,
        targetToday: Double?
    ) throws {
        let result = try CalculationEngine.calculate(input)
        self.id = UUID()
        self.input = input
        self.presetID = presetID
        self.targetToday = targetToday
        self.result = result
        self.targetAnalysis = TargetAnalyzer.analyze(
            targetToday: targetToday,
            input: input,
            result: result
        )
    }
}
