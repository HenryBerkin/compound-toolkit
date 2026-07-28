import XCTest
@testable import InvestmentGrowthCalculator

final class CodableScenarioStoreTests: XCTestCase {
    private var directoryURL: URL!

    override func setUpWithError() throws {
        directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("IGC-012-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.removeItem(at: directoryURL)
        }
    }

    func testEmptySaveMultipleLoadAndProcessRelaunchPersistence() async throws {
        let store = makeStore()
        await assertAvailable(store, expectedIDs: [])

        let first = try scenario(id: "first", name: "First", seconds: 10)
        let second = try scenario(id: "second", name: "Second", seconds: 20)
        _ = try await store.create(first)
        let afterSecond = try await store.create(second)
        XCTAssertEqual(afterSecond.scenarios.map(\.id), ["second", "first"])

        let beforeLoadData = try Data(contentsOf: documentURL)
        let loaded = try await store.scenario(id: first.id)
        let afterLoadData = try Data(contentsOf: documentURL)
        XCTAssertEqual(loaded, first)
        XCTAssertEqual(beforeLoadData, afterLoadData)

        let relaunchedStore = makeStore()
        await assertAvailable(
            relaunchedStore,
            expectedIDs: ["second", "first"]
        )
    }

    func testConcurrentCreatesAreSerialisedWithoutLosingEitherRecord() async throws {
        let store = makeStore()
        let first = try scenario(id: "concurrent-a", name: "Concurrent A", seconds: 10)
        let second = try scenario(id: "concurrent-b", name: "Concurrent B", seconds: 20)

        async let firstWrite = store.create(first)
        async let secondWrite = store.create(second)
        _ = try await (firstWrite, secondWrite)

        await assertAvailable(
            store,
            expectedIDs: ["concurrent-b", "concurrent-a"]
        )
    }

    func testRenameChangesOnlyNameAndUpdatedAt() async throws {
        let store = makeStore()
        let original = try scenario(id: "rename", name: "Original", seconds: 10)
        _ = try await store.create(original)
        let updatedAt = Date(timeIntervalSince1970: 1_800_000_100)

        let readable = try await store.rename(
            id: original.id,
            name: "  Renamed  ",
            at: updatedAt
        )
        let renamed = try XCTUnwrap(readable.scenario(id: original.id))
        XCTAssertEqual(renamed.name, "Renamed")
        XCTAssertEqual(renamed.updatedAt, updatedAt)
        XCTAssertEqual(renamed.id, original.id)
        XCTAssertEqual(renamed.createdAt, original.createdAt)
        XCTAssertEqual(renamed.inputs, original.inputs)
        XCTAssertEqual(renamed.targetToday, original.targetToday)
        XCTAssertEqual(renamed.presetID, original.presetID)
    }

    func testDuplicateCreatesFreshIdentityNameAndTimestampsThenDeleteRemovesOnlyID() async throws {
        let store = makeStore()
        let original = try scenario(id: "original", name: "Plan", seconds: 10)
        _ = try await store.create(original)

        let firstDate = Date(timeIntervalSince1970: 1_800_000_020)
        _ = try await store.duplicate(
            id: original.id,
            newID: "copy-1",
            at: firstDate
        )
        let secondDate = Date(timeIntervalSince1970: 1_800_000_030)
        let withSecond = try await store.duplicate(
            id: original.id,
            newID: "copy-2",
            at: secondDate
        )

        let first = try XCTUnwrap(withSecond.scenario(id: "copy-1"))
        let second = try XCTUnwrap(withSecond.scenario(id: "copy-2"))
        XCTAssertEqual(first.name, "Plan copy")
        XCTAssertEqual(second.name, "Plan copy 2")
        XCTAssertEqual(first.createdAt, firstDate)
        XCTAssertEqual(first.updatedAt, firstDate)
        XCTAssertEqual(first.inputs, original.inputs)
        XCTAssertEqual(first.targetToday, original.targetToday)
        XCTAssertEqual(first.presetID, original.presetID)

        let afterDelete = try await store.delete(id: "copy-1")
        XCTAssertNil(afterDelete.scenario(id: "copy-1"))
        XCTAssertNotNil(afterDelete.scenario(id: original.id))
        XCTAssertNotNil(afterDelete.scenario(id: "copy-2"))
    }

    func testUnknownStoreAndScenarioVersionsAreUnsupportedWithoutPartialDecode() async throws {
        try writeRaw(
            """
            {"storeVersion":2,"futurePayload":{"shape":"unknown"}}
            """
        )
        let storeVersionState = await makeStore().snapshot()
        guard case let .unsupported(versions, evidence) = storeVersionState else {
            return XCTFail("Expected unsupported store state")
        }
        XCTAssertEqual(versions.storeVersion, 2)
        XCTAssertNil(versions.scenarioVersion)
        XCTAssertTrue(evidence.sourcePreserved)

        try FileManager.default.removeItem(at: directoryURL)
        try writeRaw(
            """
            {"storeVersion":1,"scenarios":[{"schemaVersion":2}]}
            """
        )
        let scenarioVersionState = await makeStore().snapshot()
        guard case let .unsupported(versions, evidence) = scenarioVersionState else {
            return XCTFail("Expected unsupported scenario state")
        }
        XCTAssertEqual(versions.storeVersion, 1)
        XCTAssertEqual(versions.scenarioVersion, 2)
        XCTAssertTrue(evidence.sourcePreserved)
    }

    func testCorruptDocumentIsPreservedAndResetIsDeliberate() async throws {
        try writeRaw("{")
        let sourceData = try Data(contentsOf: documentURL)
        let store = makeStore()

        let state = await store.snapshot()
        guard case let .corrupt(evidence) = state else {
            return XCTFail("Expected corrupt state")
        }
        XCTAssertTrue(evidence.sourcePreserved)
        XCTAssertEqual(try Data(contentsOf: documentURL), sourceData)
        XCTAssertEqual(try recoveryFiles().count, 1)

        let reset = try await store.resetAfterRecovery()
        XCTAssertTrue(reset.isEmpty)
        XCTAssertEqual(try recoveryFiles().count, 1)
        await assertAvailable(store, expectedIDs: [])
    }

    func testUnavailableOrProtectedStorageIsDistinctFromEmpty() async {
        var failures = ScenarioStoreFailureInjection.none
        failures.unavailableOnRead = true
        let store = makeStore(failures: failures)
        let state = await store.snapshot()
        XCTAssertEqual(state, .unavailable)
    }

    func testInjectedTemporaryWriteFailurePreservesLastReadableDocument() async throws {
        let healthy = makeStore()
        let original = try scenario(id: "original", name: "Original", seconds: 10)
        _ = try await healthy.create(original)
        let before = try Data(contentsOf: documentURL)

        var failures = ScenarioStoreFailureInjection.none
        failures.temporaryWriteFailure = true
        let failing = makeStore(failures: failures)
        do {
            _ = try await failing.create(
                scenario(id: "new", name: "New", seconds: 20)
            )
            XCTFail("Expected temporary-write failure")
        } catch {
            XCTAssertEqual(error as? ScenarioStoreError, .temporaryWriteFailed)
        }

        XCTAssertEqual(try Data(contentsOf: documentURL), before)
        await assertAvailable(healthy, expectedIDs: ["original"])
    }

    func testInjectedReplacementFailurePreservesLastReadableDocument() async throws {
        let healthy = makeStore()
        let original = try scenario(id: "original", name: "Original", seconds: 10)
        _ = try await healthy.create(original)
        let before = try Data(contentsOf: documentURL)

        var failures = ScenarioStoreFailureInjection.none
        failures.replacementFailure = true
        let failing = makeStore(failures: failures)
        do {
            _ = try await failing.rename(
                id: original.id,
                name: "Changed",
                at: Date(timeIntervalSince1970: 1_800_000_100)
            )
            XCTFail("Expected replacement failure")
        } catch {
            XCTAssertEqual(error as? ScenarioStoreError, .replacementFailed)
        }

        XCTAssertEqual(try Data(contentsOf: documentURL), before)
        let preserved = try await healthy.scenario(id: original.id)
        XCTAssertEqual(preserved, original)
    }

    func testFailedReloadAfterMutationNeverReturnsSuccess() async throws {
        let healthy = makeStore()
        let original = try scenario(id: "original", name: "Original", seconds: 10)
        _ = try await healthy.create(original)

        var failures = ScenarioStoreFailureInjection.none
        failures.reloadAfterMutationFailure = true
        let failing = makeStore(failures: failures)
        do {
            _ = try await failing.rename(
                id: original.id,
                name: "Changed",
                at: Date(timeIntervalSince1970: 1_800_000_100)
            )
            XCTFail("Expected reload failure")
        } catch {
            XCTAssertEqual(error as? ScenarioStoreError, .reloadFailed)
        }

        let durable = try await healthy.scenario(id: original.id)
        XCTAssertEqual(durable.name, "Changed")
    }

    func testStoredDocumentUsesCompleteDataProtection() async throws {
        XCTAssertEqual(
            ScenarioStoreConfiguration.dataProtectionClass,
            .complete
        )
        let store = makeStore()
        _ = try await store.create(
            scenario(id: "protected", name: "Protected", seconds: 10)
        )
        let attributes = try FileManager.default.attributesOfItem(
            atPath: documentURL.path
        )
        if let protection = attributes[.protectionKey] as? FileProtectionType {
            XCTAssertEqual(protection, .complete)
        }
    }

    func testMalformedSemanticRecordMakesWholeDocumentCorrupt() async throws {
        let invalid = """
        {
          "storeVersion": 1,
          "scenarios": [{
            "schemaVersion": 1,
            "id": "invalid",
            "name": "Invalid",
            "currency": "GBP",
            "inputs": {
              "principal": 0,
              "contribution": 0,
              "contributionFrequency": "monthly",
              "apr": 0.07,
              "inflationRate": 0.03,
              "annualFeeRate": 0.002,
              "compoundFrequency": "monthly",
              "years": 15,
              "months": 0,
              "timing": "start"
            },
            "presetId": null,
            "createdAt": "2026-07-28T12:00:00Z",
            "updatedAt": "2026-07-28T12:00:00Z"
          }]
        }
        """
        try writeRaw(invalid)
        guard case .corrupt = await makeStore().snapshot() else {
            return XCTFail("Semantic invalidity must make the whole document corrupt")
        }
    }

    private var documentURL: URL {
        directoryURL.appendingPathComponent(
            ScenarioStoreConfiguration.documentFilename
        )
    }

    private func makeStore(
        failures: ScenarioStoreFailureInjection = .none
    ) -> CodableScenarioStore {
        CodableScenarioStore(
            configuration: ScenarioStoreConfiguration(directoryURL: directoryURL),
            failures: failures
        )
    }

    private func scenario(
        id: String,
        name: String,
        seconds: TimeInterval
    ) throws -> ScenarioV1 {
        let date = Date(timeIntervalSince1970: 1_800_000_000 + seconds)
        return try ScenarioV1(
            id: id,
            name: name,
            inputs: PresetCatalog.customBaseline,
            presetID: nil,
            targetToday: 75_000,
            createdAt: date,
            updatedAt: date
        )
    }

    private func writeRaw(_ string: String) throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        try Data(string.utf8).write(to: documentURL)
    }

    private func recoveryFiles() throws -> [URL] {
        let recoveryURL = directoryURL.appendingPathComponent(
            "Recovery",
            isDirectory: true
        )
        return try FileManager.default.contentsOfDirectory(
            at: recoveryURL,
            includingPropertiesForKeys: nil
        )
    }

    private func assertAvailable(
        _ store: CodableScenarioStore,
        expectedIDs: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let state = await store.snapshot()
        guard case let .available(readable) = state else {
            return XCTFail("Expected readable state, got \(state)", file: file, line: line)
        }
        XCTAssertEqual(readable.scenarios.map(\.id), expectedIDs, file: file, line: line)
    }
}
