import XCTest
@testable import InvestmentGrowthCalculator

final class AppPreferencesAndContentTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        suiteName = "uk.co.mochadesigns.igc.tests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
    }

    @MainActor
    func testPreferenceDefaultsStableValuesWritesAndOwnedKeysOnly() throws {
        let store = UserDefaultsAppPreferencesStore(defaults: defaults)
        XCTAssertEqual(store.load(), .defaults)

        XCTAssertEqual(
            try store.setAppearance(.light),
            AppPreferenceSnapshot(appearance: .light, coachDismissed: false)
        )
        XCTAssertEqual(
            defaults.string(forKey: UserDefaultsAppPreferencesStore.appearanceKey),
            "light"
        )
        XCTAssertEqual(
            try store.setAppearance(.dark),
            AppPreferenceSnapshot(appearance: .dark, coachDismissed: false)
        )
        XCTAssertEqual(
            defaults.string(forKey: UserDefaultsAppPreferencesStore.appearanceKey),
            "dark"
        )
        XCTAssertEqual(
            try store.setAppearance(.system),
            AppPreferenceSnapshot(appearance: .system, coachDismissed: false)
        )
        XCTAssertEqual(
            defaults.string(forKey: UserDefaultsAppPreferencesStore.appearanceKey),
            "system"
        )

        XCTAssertTrue(try store.dismissCoach().coachDismissed)
        let persistentKeys = Set(
            defaults.persistentDomain(forName: suiteName)?.keys.map { $0 } ?? []
        )
        XCTAssertEqual(
            persistentKeys,
            UserDefaultsAppPreferencesStore.ownedKeys
        )
    }

    @MainActor
    func testUnknownAppearanceFallsBackToSystemWithoutInventingMigration() {
        defaults.set(
            "future-theme",
            forKey: UserDefaultsAppPreferencesStore.appearanceKey
        )
        let store = UserDefaultsAppPreferencesStore(defaults: defaults)

        XCTAssertEqual(store.load().appearance, .system)
        XCTAssertEqual(
            defaults.string(forKey: UserDefaultsAppPreferencesStore.appearanceKey),
            "future-theme"
        )
    }

    @MainActor
    func testPreferenceRelaunchReadsAppearanceAndCoachDismissal() throws {
        let firstStore = UserDefaultsAppPreferencesStore(defaults: defaults)
        _ = try firstStore.setAppearance(.dark)
        _ = try firstStore.dismissCoach()

        let relaunchedStore = UserDefaultsAppPreferencesStore(defaults: defaults)
        XCTAssertEqual(
            relaunchedStore.load(),
            AppPreferenceSnapshot(appearance: .dark, coachDismissed: true)
        )
    }

    @MainActor
    func testInjectedWriteFailuresKeepSessionUsableWithoutFalsePersistence() {
        var failures = AppPreferencesFailureInjection.none
        failures.appearanceWriteFailure = true
        failures.coachWriteFailure = true
        let store = UserDefaultsAppPreferencesStore(
            defaults: defaults,
            failures: failures
        )
        let model = AppPreferencesModel(store: store)

        model.chooseAppearance(.dark)
        XCTAssertEqual(model.appearance, .dark)
        XCTAssertEqual(store.load().appearance, .system)
        XCTAssertEqual(
            model.message,
            "Appearance changed for this session, but the preference was not saved."
        )

        model.dismissCoach()
        XCTAssertFalse(model.showsCoach)
        XCTAssertFalse(store.load().coachDismissed)
        let relaunched = AppPreferencesModel(
            store: UserDefaultsAppPreferencesStore(defaults: defaults)
        )
        XCTAssertTrue(relaunched.showsCoach)
    }

    @MainActor
    func testResetRemovesOnlyOwnedKeysAndVerifiesDefaults() throws {
        defaults.set("keep", forKey: "unrelated.test.key")
        let store = UserDefaultsAppPreferencesStore(defaults: defaults)
        _ = try store.setAppearance(.light)
        _ = try store.dismissCoach()

        XCTAssertEqual(try store.reset(), .defaults)
        XCTAssertEqual(defaults.string(forKey: "unrelated.test.key"), "keep")
        XCTAssertNil(
            defaults.object(forKey: UserDefaultsAppPreferencesStore.appearanceKey)
        )
        XCTAssertNil(
            defaults.object(forKey: UserDefaultsAppPreferencesStore.coachDismissedKey)
        )
    }

    @MainActor
    func testInjectedPartialResetIsReportedAndRetryCompletes() throws {
        var failures = AppPreferencesFailureInjection.none
        failures.resetFailureAfterAppearanceRemovalCount = 1
        let store = UserDefaultsAppPreferencesStore(
            defaults: defaults,
            failures: failures
        )
        _ = try store.setAppearance(.dark)
        _ = try store.dismissCoach()

        XCTAssertThrowsError(try store.reset()) { error in
            XCTAssertEqual(error as? AppPreferenceError, .resetFailed)
        }
        XCTAssertEqual(store.load().appearance, .system)
        XCTAssertTrue(store.load().coachDismissed)

        XCTAssertEqual(try store.reset(), .defaults)
    }

    func testBundledEducationHierarchyGlossaryAndMethodologyAreComplete() {
        XCTAssertEqual(
            GlossaryTerm.allCases.map(\.title),
            [
                "Annual growth rate",
                "Compounding",
                "Inflation",
                "Annual fee",
                "After fees",
                "Today’s money / purchasing power",
                "Contribution frequency",
                "Contribution timing",
                "Preset and Custom",
                "Target",
            ]
        )

        let methodology = EducationArticle.calculations.sections
            .flatMap(\.paragraphs)
            .joined(separator: " ")
        for requiredText in [
            "month by month",
            "compounding frequency",
            "amount × 52 ÷ 12",
            "amount ÷ 12",
            "start-of-period",
            "end-of-period",
            "growth occurs before the asset-based fee deduction",
            "inflation assumption",
            "remain constant",
            "deterministic projection",
        ] {
            XCTAssertTrue(
                methodology.localizedCaseInsensitiveContains(requiredText),
                "Missing methodology text: \(requiredText)"
            )
        }
        XCTAssertFalse(methodology.localizedCaseInsensitiveContains("expected return"))
        XCTAssertEqual(
            EducationContent.projectionDisclaimer,
            "IGC creates an illustrative projection from the assumptions you enter. It is not financial advice, a forecast, or a recommendation. Rates and contributions are held constant. The calculation does not model taxes, market volatility or the order of returns, changing inflation, contribution limits, platform or transaction charges beyond the annual fee you enter, pension or ISA rules, withdrawals, or investment losses along a market path. Actual outcomes may be higher or lower."
        )
    }

    func testAboutUsesActualHostAppBundleVersionAndBuild() {
        let version = AppVersionInfo(bundle: .main)
        XCTAssertEqual(
            version.version,
            Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String
        )
        XCTAssertEqual(
            version.build,
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        )
        XCTAssertNotEqual(version.version, "Not available")
        XCTAssertNotEqual(version.build, "Not available")
    }

    func testPrivacyManifestIsInHostBundleAndHasOnlyApprovedDeclaration() throws {
        let manifestURL = try XCTUnwrap(
            Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy")
        )
        let data = try Data(contentsOf: manifestURL)
        let propertyList = try XCTUnwrap(
            PropertyListSerialization.propertyList(
                from: data,
                format: nil
            ) as? [String: Any]
        )
        XCTAssertEqual(Set(propertyList.keys), ["NSPrivacyAccessedAPITypes"])

        let declarations = try XCTUnwrap(
            propertyList["NSPrivacyAccessedAPITypes"] as? [[String: Any]]
        )
        XCTAssertEqual(declarations.count, 1)
        let declaration = try XCTUnwrap(declarations.first)
        XCTAssertEqual(
            Set(declaration.keys),
            [
                "NSPrivacyAccessedAPIType",
                "NSPrivacyAccessedAPITypeReasons",
            ]
        )
        XCTAssertEqual(
            declaration["NSPrivacyAccessedAPIType"] as? String,
            "NSPrivacyAccessedAPICategoryUserDefaults"
        )
        XCTAssertEqual(
            declaration["NSPrivacyAccessedAPITypeReasons"] as? [String],
            ["CA92.1"]
        )
    }
}

final class AppDataResetCoordinatorTests: XCTestCase {
    private var directoryURL: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("IGC-013-reset-\(UUID().uuidString)")
        suiteName = "uk.co.mochadesigns.igc.reset-tests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.removeItem(at: directoryURL)
        }
    }

    @MainActor
    func testCoordinatorReportsSuccessOnlyAfterBothStoresVerifyDefaults() async throws {
        let scenarioStore = CodableScenarioStore(
            configuration: ScenarioStoreConfiguration(directoryURL: directoryURL)
        )
        _ = try await scenarioStore.create(try scenario(id: "saved"))
        let library = ScenarioLibraryModel(store: scenarioStore)
        await library.refresh()

        let preferenceStore = UserDefaultsAppPreferencesStore(defaults: defaults)
        let preferences = AppPreferencesModel(store: preferenceStore)
        preferences.chooseAppearance(.dark)
        preferences.dismissCoach()

        let result = await AppDataResetCoordinator.execute(
            scenarioLibrary: library,
            preferences: preferences
        )

        XCTAssertEqual(result, .success)
        guard case let .available(readable)? = library.snapshot else {
            return XCTFail("Expected verified available scenario store")
        }
        XCTAssertTrue(readable.isEmpty)
        XCTAssertEqual(preferences.snapshot, .defaults)
        XCTAssertTrue(preferences.showsCoach)
    }

    @MainActor
    func testCoordinatorReportsPartialPreferenceFailureAndRetry() async throws {
        let scenarioStore = CodableScenarioStore(
            configuration: ScenarioStoreConfiguration(directoryURL: directoryURL)
        )
        _ = try await scenarioStore.create(try scenario(id: "saved"))
        let library = ScenarioLibraryModel(store: scenarioStore)
        await library.refresh()

        var failures = AppPreferencesFailureInjection.none
        failures.resetFailureAfterAppearanceRemovalCount = 1
        let preferenceStore = UserDefaultsAppPreferencesStore(
            defaults: defaults,
            failures: failures
        )
        let preferences = AppPreferencesModel(store: preferenceStore)
        preferences.chooseAppearance(.dark)
        preferences.dismissCoach()

        let first = await AppDataResetCoordinator.execute(
            scenarioLibrary: library,
            preferences: preferences
        )
        XCTAssertFalse(first.completed)
        XCTAssertTrue(first.message.contains("Deletion did not complete"))
        XCTAssertTrue(first.message.contains("coach dismissal"))
        XCTAssertFalse(first.message.contains("All app data deleted"))

        let retry = await AppDataResetCoordinator.execute(
            scenarioLibrary: library,
            preferences: preferences
        )
        XCTAssertEqual(retry, .success)
    }

    @MainActor
    func testCoordinatorRelaunchAfterPartialScenarioErasureCanVerifyRetry() async throws {
        let healthyStore = CodableScenarioStore(
            configuration: ScenarioStoreConfiguration(directoryURL: directoryURL)
        )
        _ = try await healthyStore.create(try scenario(id: "saved"))

        var failures = ScenarioStoreFailureInjection.none
        failures.eraseAllDataFailureAfterDocumentRemovalCount = 1
        let failingStore = CodableScenarioStore(
            configuration: ScenarioStoreConfiguration(directoryURL: directoryURL),
            failures: failures
        )
        let firstLibrary = ScenarioLibraryModel(store: failingStore)
        await firstLibrary.refresh()
        let firstPreferences = AppPreferencesModel(
            store: UserDefaultsAppPreferencesStore(defaults: defaults)
        )
        firstPreferences.chooseAppearance(.dark)
        firstPreferences.dismissCoach()

        let first = await AppDataResetCoordinator.execute(
            scenarioLibrary: firstLibrary,
            preferences: firstPreferences
        )
        XCTAssertFalse(first.completed)
        XCTAssertTrue(first.message.contains("Deletion did not complete"))

        let relaunchedStore = CodableScenarioStore(
            configuration: ScenarioStoreConfiguration(directoryURL: directoryURL)
        )
        let relaunchedLibrary = ScenarioLibraryModel(store: relaunchedStore)
        await relaunchedLibrary.refresh()
        let relaunchedPreferences = AppPreferencesModel(
            store: UserDefaultsAppPreferencesStore(defaults: defaults)
        )

        let retry = await AppDataResetCoordinator.execute(
            scenarioLibrary: relaunchedLibrary,
            preferences: relaunchedPreferences
        )
        XCTAssertEqual(retry, .success)
        guard case let .available(readable)? = relaunchedLibrary.snapshot else {
            return XCTFail("Expected verified empty store after relaunch retry")
        }
        XCTAssertTrue(readable.isEmpty)
        XCTAssertEqual(relaunchedPreferences.snapshot, .defaults)
    }

    private func scenario(id: String) throws -> ScenarioV1 {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        return try ScenarioV1(
            id: id,
            name: "Reset test",
            inputs: PresetCatalog.customBaseline,
            presetID: nil,
            targetToday: nil,
            createdAt: date,
            updatedAt: date
        )
    }
}
