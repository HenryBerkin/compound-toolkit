import XCTest
@testable import InvestmentGrowthCalculator

final class CoreInvariantTests: XCTestCase {
    func testCustomBaselineAndDeliberatePresetTransition() {
        var draft = CalculatorDraft.customBaseline
        XCTAssertNil(draft.presetID)
        XCTAssertEqual(draft.fee, "0.20")

        draft.selectPreset(.globalIndexDIY)
        XCTAssertEqual(draft.presetID, .globalIndexDIY)
        XCTAssertEqual(draft.fee, "0.4")

        draft.apr = "6.9"
        draft.reconcilePreset()
        XCTAssertNil(draft.presetID)
        XCTAssertEqual(draft.fee, "0.4")
    }

    func testAllPresetsApplyAndMatchOnlyControlledFields() {
        for preset in PresetCatalog.all {
            var draft = CalculatorDraft.customBaseline
            draft.selectPreset(preset.id)
            let candidate = try! XCTUnwrap(draft.parsed().candidate)
            XCTAssertTrue(preset.matches(candidate))
            candidate.principal == 10_000
                ? XCTAssertEqual(
                    PresetCatalog.truthfulSelection(persisted: preset.id, candidate: candidate),
                    preset.id
                )
                : XCTFail("Uncontrolled field changed")
        }
    }

    func testOneTwelveThirteenAndSevenHundredTwentyPeriodAggregation() throws {
        for duration in [1, 12, 13, 720] {
            var input = PresetCatalog.customBaseline
            input.years = duration / 12
            input.months = duration % 12
            let result = try CalculationEngine.calculate(input)
            XCTAssertEqual(result.monthlyRows.count, duration)
            XCTAssertEqual(result.annualRows.count, (duration + 11) / 12)
            XCTAssertEqual(result.annualRows.last?.endPeriod, duration)
            XCTAssertEqual(result.annualRows.reduce(0) { $0 + $1.periodCount }, duration)
        }
    }

    func testZeroRatesAndAllFrequencyTimingEnums() throws {
        for contributionFrequency in ContributionFrequency.allCases {
            for compoundFrequency in CompoundFrequency.allCases {
                for timing in ContributionTiming.allCases {
                    var input = PresetCatalog.customBaseline
                    input.apr = 0
                    input.inflationRate = 0
                    input.annualFeeRate = 0
                    input.contributionFrequency = contributionFrequency
                    input.compoundFrequency = compoundFrequency
                    input.timing = timing
                    input.years = 0
                    input.months = 1
                    let result = try CalculationEngine.calculate(input)
                    XCTAssertEqual(result.effectiveMonthlyRate, 0)
                    XCTAssertEqual(result.effectiveMonthlyFeeRate, 0)
                    XCTAssertEqual(result.finalBalance, result.finalBalanceAfterFees)
                    XCTAssertEqual(result.finalBalance, input.principal + result.effectiveMonthlyContribution)
                }
            }
        }
    }

    func testNoIntermediateRounding() throws {
        let result = try CalculationEngine.calculate(PresetCatalog.customBaseline)
        let first = try XCTUnwrap(result.monthlyRows.first)
        XCTAssertNotEqual(first.endingBalance, (first.endingBalance * 100).rounded() / 100)
        XCTAssertEqual(result.monthlyRows[1].startingBalance, first.endingBalance)
        XCTAssertEqual(result.finalBalanceAfterFees, 105_958.16046332686, accuracy: 0.000001)
    }

    func testNonFiniteRejectionUsesExactCanonicalField() {
        var candidate = PresetCatalog.customBaseline.candidate
        candidate.apr = .infinity
        let result = CalculationValidator.validate(candidate)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorFields, [.apr])
    }

    func testRawTargetClassifiesEqualAndSubPennyWithoutDisplayTolerance() throws {
        let input = PresetCatalog.customBaseline
        let result = try CalculationEngine.calculate(input)
        let equal = try XCTUnwrap(TargetAnalyzer.analyze(
            targetToday: result.finalBalanceAfterFeesReal,
            input: input,
            result: result
        ))
        XCTAssertEqual(equal.status, .equal)
        XCTAssertEqual(equal.rawGap, 0)

        let subPenny = try XCTUnwrap(TargetAnalyzer.analyze(
            targetToday: result.finalBalanceAfterFeesReal - 0.004,
            input: input,
            result: result
        ))
        XCTAssertEqual(subPenny.status, .above)
        XCTAssertGreaterThan(subPenny.rawGap, 0)
        XCTAssertEqual(
            IGCFormatters.targetGapText(subPenny),
            "Less than £0.01 above the target in today’s money."
        )
    }

    func testTargetNeverChangesEngineResult() throws {
        let input = PresetCatalog.customBaseline
        let before = try CalculationEngine.calculate(input)
        _ = TargetAnalyzer.analyze(targetToday: 100_000, input: input, result: before)
        let after = try CalculationEngine.calculate(input)
        XCTAssertEqual(before, after)
    }

    func testGBPAndPercentageFormattingAreFixedToUKContract() {
        XCTAssertEqual(IGCFormatters.gbp(1.005), "£1.01")
        XCTAssertEqual(IGCFormatters.gbp(-1.005), "-£1.01")
        XCTAssertEqual(IGCFormatters.gbp(1234567.8), "£1,234,567.80")
        XCTAssertEqual(IGCFormatters.percent(0.07), "7.00%")
    }

    func testFeatureAvailabilityIsLocalAndFree() {
        let availability = LocalFreeAvailability()
        XCTAssertTrue(AppFeature.allCases.allSatisfy(availability.isAvailable))
    }
}
