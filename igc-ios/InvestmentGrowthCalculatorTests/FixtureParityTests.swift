import XCTest
@testable import InvestmentGrowthCalculator

final class FixtureParityTests: XCTestCase {
    private var fixture: CalculationFixtureEnvelope!
    private var source: URL!

    override func setUpWithError() throws {
        let loaded = try CalculationFixtureLoader.load(bundle: Bundle(for: Self.self))
        fixture = loaded.fixture
        source = loaded.source
        print("IGC direct fixture: contractVersion=\(fixture.contractVersion), currency=\(fixture.currency), source=\(source.path)")
    }

    func testDirectVersionOneFixtureParity() throws {
        XCTAssertEqual(fixture.contractVersion, 1)
        XCTAssertEqual(fixture.currency, "GBP")
        XCTAssertEqual(fixture.calculationCases.count, 7)

        for testCase in fixture.calculationCases {
            let validation = CalculationValidator.validate(testCase.input)
            let input = try XCTUnwrap(validation.input, "Fixture case \(testCase.id) must validate")
            let result = try CalculationEngine.calculate(input)

            assertRate(result.effectiveMonthlyRate, testCase.expectedMonthlyRate, caseID: testCase.id)
            assertNumber(
                result.effectiveMonthlyContribution,
                testCase.expectedMonthlyContribution,
                caseID: testCase.id,
                field: "effectiveMonthlyContribution"
            )
            assertExpected(result, testCase: testCase)
            assertMonthlyCheckpoints(result, testCase: testCase)
            assertAnnualCheckpoints(result, testCase: testCase)
            assertStructure(result, input: input, caseID: testCase.id)
        }
    }

    func testEveryFixtureValidationExpectation() {
        XCTAssertEqual(fixture.validationCases.count, 19)
        for testCase in fixture.validationCases {
            let result = CalculationValidator.validate(testCase.candidate)
            XCTAssertEqual(result.isValid, testCase.valid, "Validation validity: \(testCase.id)")
            XCTAssertEqual(result.errorFields, testCase.errorFields, "Validation fields: \(testCase.id)")
        }
    }

    func testLoaderRejectsMissingMalformedUnsupportedVersionAndCurrency() throws {
        XCTAssertThrowsError(
            try CalculationFixtureLoader.load(
                resource: "does-not-exist",
                bundle: Bundle(for: Self.self)
            )
        ) { error in
            XCTAssertEqual(error as? FixtureLoaderError, .missingResource("does-not-exist.json"))
        }

        XCTAssertThrowsError(try CalculationFixtureLoader.decode(Data("{".utf8))) { error in
            guard case .malformed = error as? FixtureLoaderError else {
                return XCTFail("Expected malformed fixture, got \(error)")
            }
        }

        let unsupportedVersion = """
        {"contractVersion":2,"currency":"GBP","tolerances":{"absolute":1,"relative":1,"rateAbsolute":1},"calculationCases":[{}],"validationCases":[{}]}
        """
        XCTAssertThrowsError(try CalculationFixtureLoader.decode(Data(unsupportedVersion.utf8))) { error in
            guard case .malformed = error as? FixtureLoaderError else {
                return XCTFail("Structural decoding must fail clearly before unsupported data executes")
            }
        }

        let originalData = try Data(contentsOf: source)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: originalData) as? [String: Any]
        )
        var versionObject = object
        versionObject["contractVersion"] = 2
        XCTAssertThrowsError(
            try CalculationFixtureLoader.decode(JSONSerialization.data(withJSONObject: versionObject))
        ) { error in
            XCTAssertEqual(error as? FixtureLoaderError, .unsupportedContractVersion(2))
        }

        var currencyObject = object
        currencyObject["currency"] = "USD"
        XCTAssertThrowsError(
            try CalculationFixtureLoader.decode(JSONSerialization.data(withJSONObject: currencyObject))
        ) { error in
            XCTAssertEqual(error as? FixtureLoaderError, .unsupportedCurrency("USD"))
        }
    }

    func testSchemaResourcesAreDirectlyBundled() throws {
        let bundle = Bundle(for: Self.self)
        let fixtureSchema = try XCTUnwrap(
            bundle.url(forResource: "calculation-fixture-v1.schema", withExtension: "json")
        )
        let scenarioSchema = try XCTUnwrap(
            bundle.url(forResource: "scenario-v1.schema", withExtension: "json")
        )
        let fixtureSchemaText = try String(contentsOf: fixtureSchema, encoding: .utf8)
        let scenarioSchemaText = try String(contentsOf: scenarioSchema, encoding: .utf8)
        XCTAssertTrue(fixtureSchemaText.contains("urn:igc:schema:calculation-fixture:v1"))
        XCTAssertTrue(scenarioSchemaText.contains("urn:igc:schema:scenario:v1"))
        print("IGC schema resources: \(fixtureSchema.path), \(scenarioSchema.path)")
    }

    private func assertExpected(
        _ result: CalculationResult,
        testCase: FixtureCalculationCase
    ) {
        let expected = testCase.expected
        assertNumber(result.finalBalance, expected.finalBalance, caseID: testCase.id, field: "finalBalance")
        assertNumber(result.totalContributions, expected.totalContributions, caseID: testCase.id, field: "totalContributions")
        assertNumber(result.totalInterest, expected.totalInterest, caseID: testCase.id, field: "totalInterest")
        assertNumber(result.totalFeesPaidNominal, expected.totalFeesPaidNominal, caseID: testCase.id, field: "totalFeesPaidNominal")
        assertNumber(result.finalBalanceAfterFees, expected.finalBalanceAfterFees, caseID: testCase.id, field: "finalBalanceAfterFees")
        assertNumber(result.finalBalanceReal, expected.finalBalanceReal, caseID: testCase.id, field: "finalBalanceReal")
        assertNumber(result.totalContributionsReal, expected.totalContributionsReal, caseID: testCase.id, field: "totalContributionsReal")
        assertNumber(result.totalInterestReal, expected.totalInterestReal, caseID: testCase.id, field: "totalInterestReal")
        assertNumber(result.totalFeesPaidReal, expected.totalFeesPaidReal, caseID: testCase.id, field: "totalFeesPaidReal")
        assertNumber(result.finalBalanceAfterFeesReal, expected.finalBalanceAfterFeesReal, caseID: testCase.id, field: "finalBalanceAfterFeesReal")
        XCTAssertEqual(result.monthlyRows.count, expected.monthlyCount, "\(testCase.id).monthlyCount")
        XCTAssertEqual(result.annualRows.count, expected.yearlyCount, "\(testCase.id).yearlyCount")
    }

    private func assertMonthlyCheckpoints(
        _ result: CalculationResult,
        testCase: FixtureCalculationCase
    ) {
        for expected in testCase.monthlyCheckpoints {
            guard let actual = result.monthlyRows.first(where: { $0.period == expected.period }) else {
                return XCTFail("\(testCase.id): missing monthly period \(expected.period)")
            }
            XCTAssertEqual(actual.period, expected.period)
            XCTAssertEqual(actual.year, expected.year)
            XCTAssertEqual(actual.month, expected.month)
            assertNumber(actual.startingBalance, expected.startingBalance, caseID: testCase.id, field: "month.startingBalance")
            assertNumber(actual.contributions, expected.contributions, caseID: testCase.id, field: "month.contributions")
            assertNumber(actual.interest, expected.interest, caseID: testCase.id, field: "month.interest")
            assertNumber(actual.endingBalance, expected.endingBalance, caseID: testCase.id, field: "month.endingBalance")
            assertNumber(actual.cumulativeContributions, expected.cumulativeContributions, caseID: testCase.id, field: "month.cumulativeContributions")
            assertNumber(actual.cumulativeInterest, expected.cumulativeInterest, caseID: testCase.id, field: "month.cumulativeInterest")
        }
    }

    private func assertAnnualCheckpoints(
        _ result: CalculationResult,
        testCase: FixtureCalculationCase
    ) {
        for expected in testCase.yearlyCheckpoints {
            guard let actual = result.annualRows.first(where: { $0.year == expected.year }) else {
                return XCTFail("\(testCase.id): missing annual year \(expected.year)")
            }
            assertNumber(actual.startingBalance, expected.startingBalance, caseID: testCase.id, field: "year.startingBalance")
            assertNumber(actual.contributions, expected.contributions, caseID: testCase.id, field: "year.contributions")
            assertNumber(actual.interest, expected.interest, caseID: testCase.id, field: "year.interest")
            assertNumber(actual.endingBalance, expected.endingBalance, caseID: testCase.id, field: "year.endingBalance")
            assertNumber(actual.cumulativeContributions, expected.cumulativeContributions, caseID: testCase.id, field: "year.cumulativeContributions")
            assertNumber(actual.cumulativeInterest, expected.cumulativeInterest, caseID: testCase.id, field: "year.cumulativeInterest")
            assertNumber(actual.yearlyFeesPaid, expected.yearlyFeesPaid, caseID: testCase.id, field: "year.yearlyFeesPaid")
            assertNumber(actual.cumulativeFeesPaid, expected.cumulativeFeesPaid, caseID: testCase.id, field: "year.cumulativeFeesPaid")
            assertNumber(actual.endingBalanceAfterFees, expected.endingBalanceAfterFees, caseID: testCase.id, field: "year.endingBalanceAfterFees")
            assertNumber(actual.realEndingBalance, expected.realEndingBalance, caseID: testCase.id, field: "year.realEndingBalance")
            assertNumber(actual.realCumulativeContributions, expected.realCumulativeContributions, caseID: testCase.id, field: "year.realCumulativeContributions")
            assertNumber(actual.realCumulativeInterest, expected.realCumulativeInterest, caseID: testCase.id, field: "year.realCumulativeInterest")
        }
    }

    private func assertStructure(
        _ result: CalculationResult,
        input: CalculationInput,
        caseID: String
    ) {
        XCTAssertEqual(result.monthlyRows.map(\.period), Array(1...input.totalMonths), "\(caseID): period continuity")
        for (index, row) in result.monthlyRows.enumerated() {
            XCTAssertEqual(row.year, (row.period + 11) / 12, "\(caseID): year index")
            XCTAssertEqual(row.month, ((row.period - 1) % 12) + 1, "\(caseID): month index")
            if index > 0 {
                let prior = result.monthlyRows[index - 1]
                assertNumber(row.startingBalance, prior.endingBalance, caseID: caseID, field: "monthly continuity")
                assertNumber(row.startingBalanceAfterFees, prior.endingBalanceAfterFees, caseID: caseID, field: "after-fee continuity")
            }
        }
        XCTAssertEqual(result.annualRows.last?.endPeriod, input.totalMonths)
        XCTAssertEqual(result.annualRows.reduce(0) { $0 + $1.periodCount }, input.totalMonths)
        if input.months > 0 {
            XCTAssertEqual(result.annualRows.last?.periodCount, input.months, "\(caseID): partial final year")
            XCTAssertEqual(result.annualRows.last?.isPartial, true)
        }
    }

    private func assertRate(_ actual: Double, _ expected: Double, caseID: String) {
        XCTAssertLessThanOrEqual(
            abs(actual - expected),
            fixture.tolerances.rateAbsolute,
            "\(caseID).effectiveMonthlyRate expected \(expected), actual \(actual)"
        )
    }

    private func assertNumber(
        _ actual: Double,
        _ expected: Double,
        caseID: String,
        field: String
    ) {
        let tolerance = max(
            fixture.tolerances.absolute,
            fixture.tolerances.relative * max(1, abs(expected))
        )
        XCTAssertLessThanOrEqual(
            abs(actual - expected),
            tolerance,
            "\(caseID).\(field) expected \(expected), actual \(actual), tolerance \(tolerance)"
        )
    }
}
