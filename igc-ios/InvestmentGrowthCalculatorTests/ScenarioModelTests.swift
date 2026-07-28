import XCTest
@testable import InvestmentGrowthCalculator

final class ScenarioModelTests: XCTestCase {
    func testDirectPortableExampleDecodesAndReencodesExactV1Fields() throws {
        let url = try XCTUnwrap(
            Bundle(for: Self.self).url(
                forResource: "scenario-v1.example",
                withExtension: "json"
            )
        )
        let scenario = try ScenarioJSONCodec.decode(
            ScenarioV1.self,
            from: Data(contentsOf: url)
        )

        XCTAssertEqual(scenario.schemaVersion, 1)
        XCTAssertEqual(scenario.id, "018f4e63-a889-7c64-a3d2-6e8b145c8b18")
        XCTAssertEqual(scenario.name, "My baseline")
        XCTAssertEqual(scenario.currency, .GBP)
        XCTAssertEqual(scenario.inputs, PresetCatalog.customBaseline)
        XCTAssertNil(scenario.presetID)
        XCTAssertEqual(scenario.targetToday, 75_000)
        XCTAssertEqual(
            scenario.createdAt,
            try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-07-28T12:00:00Z"))
        )

        let encoded = try ScenarioJSONCodec.encode(scenario)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        XCTAssertEqual(
            Set(object.keys),
            [
                "schemaVersion", "id", "name", "currency", "inputs", "presetId",
                "targetToday", "createdAt", "updatedAt",
            ]
        )
        XCTAssertEqual(object["schemaVersion"] as? Int, 1)
        XCTAssertEqual(object["currency"] as? String, "GBP")
        XCTAssertEqual(object["presetId"] as? NSNull, NSNull())
        XCTAssertEqual(object["createdAt"] as? String, "2026-07-28T12:00:00Z")

        let inputs = try XCTUnwrap(object["inputs"] as? [String: Any])
        XCTAssertEqual(
            Set(inputs.keys),
            [
                "principal", "contribution", "contributionFrequency", "apr",
                "inflationRate", "annualFeeRate", "compoundFrequency", "years",
                "months", "timing",
            ]
        )
    }

    func testDecoderRejectsUnknownKeysUnknownEnumsAndSemanticInvalidity() throws {
        let exampleURL = try XCTUnwrap(
            Bundle(for: Self.self).url(
                forResource: "scenario-v1.example",
                withExtension: "json"
            )
        )
        let original = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: exampleURL))
                as? [String: Any]
        )

        var extraKey = original
        extraKey["futureField"] = true
        XCTAssertThrowsError(
            try ScenarioJSONCodec.decode(
                ScenarioV1.self,
                from: JSONSerialization.data(withJSONObject: extraKey)
            )
        )

        var unknownEnum = original
        var unknownEnumInputs = try XCTUnwrap(
            unknownEnum["inputs"] as? [String: Any]
        )
        unknownEnumInputs["timing"] = "middle"
        unknownEnum["inputs"] = unknownEnumInputs
        XCTAssertThrowsError(
            try ScenarioJSONCodec.decode(
                ScenarioV1.self,
                from: JSONSerialization.data(withJSONObject: unknownEnum)
            )
        )

        var semantic = original
        var semanticInputs = try XCTUnwrap(semantic["inputs"] as? [String: Any])
        semanticInputs["principal"] = 0
        semanticInputs["contribution"] = 0
        semantic["inputs"] = semanticInputs
        XCTAssertThrowsError(
            try ScenarioJSONCodec.decode(
                ScenarioV1.self,
                from: JSONSerialization.data(withJSONObject: semantic)
            )
        )
    }

    func testNamesTrimValidatePortableCodePointsAndDistinguishTargetAbsenceFromZero() throws {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let trimmed = try scenario(
            id: "trimmed",
            name: "  A name  ",
            target: nil,
            date: date
        )
        XCTAssertEqual(trimmed.name, "A name")
        let trimmedObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: ScenarioJSONCodec.encode(trimmed))
                as? [String: Any]
        )
        XCTAssertNil(trimmedObject["targetToday"])

        let zero = try scenario(
            id: "zero",
            name: String(repeating: "a", count: 120),
            target: 0,
            date: date
        )
        let zeroObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: ScenarioJSONCodec.encode(zero))
                as? [String: Any]
        )
        XCTAssertEqual(zeroObject["targetToday"] as? Double, 0)

        XCTAssertThrowsError(
            try scenario(id: "empty", name: " \n ", target: nil, date: date)
        )
        XCTAssertThrowsError(
            try scenario(
                id: "long",
                name: String(repeating: "a", count: 121),
                target: nil,
                date: date
            )
        )
    }

    func testDuplicateNameUsesLegalGraphemeSafeSuffixAndCollisionSequence() throws {
        let family = "👨‍👩‍👧‍👦"
        let original = String(repeating: "a", count: 113) + family
        XCTAssertLessThanOrEqual(
            ScenarioNameValidator.portableLength(of: original),
            120
        )

        let first = try ScenarioDuplicateNamer.availableName(
            for: original,
            existingNames: []
        )
        XCTAssertTrue(first.hasSuffix(" copy"))
        XCTAssertLessThanOrEqual(
            ScenarioNameValidator.portableLength(of: first),
            120
        )
        XCTAssertFalse(first.contains("�"))

        let second = try ScenarioDuplicateNamer.availableName(
            for: original,
            existingNames: [first]
        )
        XCTAssertTrue(second.hasSuffix(" copy 2"))
        XCTAssertLessThanOrEqual(
            ScenarioNameValidator.portableLength(of: second),
            120
        )
    }

    func testOrderingUsesUpdatedThenCreatedThenID() throws {
        let base = Date(timeIntervalSince1970: 1_800_000_000)
        let scenarios = try [
            scenario(id: "c", name: "C", date: base),
            scenario(id: "b", name: "B", date: base),
            ScenarioV1(
                id: "z",
                name: "Z",
                inputs: PresetCatalog.customBaseline,
                presetID: nil,
                targetToday: nil,
                createdAt: base.addingTimeInterval(1),
                updatedAt: base
            ),
            ScenarioV1(
                id: "old",
                name: "Old",
                inputs: PresetCatalog.customBaseline,
                presetID: nil,
                targetToday: nil,
                createdAt: base,
                updatedAt: base.addingTimeInterval(-1)
            ),
        ]

        XCTAssertEqual(
            ScenarioOrdering.sorted(scenarios).map(\.id),
            ["z", "b", "c", "old"]
        )
    }

    func testPresetMismatchLoadsAsCustomWithoutChangingScenario() throws {
        var input = PresetCatalog.customBaseline
        input.annualFeeRate = 0.002
        let scenario = try ScenarioV1(
            id: "mismatch",
            name: "Mismatch",
            inputs: input,
            presetID: .globalIndexDIY,
            targetToday: 0,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )

        let draft = CalculatorDraft(scenario: scenario)
        XCTAssertNil(draft.presetID)
        XCTAssertEqual(scenario.presetID, .globalIndexDIY)
        XCTAssertEqual(draft.validation().input, scenario.inputs)
        XCTAssertEqual(draft.parsed().targetToday, 0)
    }

    func testModelRejectsNonFiniteTimestamps() {
        XCTAssertThrowsError(
            try ScenarioV1(
                id: "invalid-date",
                name: "Invalid date",
                inputs: PresetCatalog.customBaseline,
                presetID: nil,
                targetToday: nil,
                createdAt: Date(timeIntervalSinceReferenceDate: .infinity),
                updatedAt: Date()
            )
        )
    }

    private func scenario(
        id: String,
        name: String,
        target: Double? = nil,
        date: Date
    ) throws -> ScenarioV1 {
        try ScenarioV1(
            id: id,
            name: name,
            inputs: PresetCatalog.customBaseline,
            presetID: nil,
            targetToday: target,
            createdAt: date,
            updatedAt: date
        )
    }
}
