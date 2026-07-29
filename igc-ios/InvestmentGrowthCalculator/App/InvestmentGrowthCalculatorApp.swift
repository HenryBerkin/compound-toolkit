import SwiftUI

@main
struct InvestmentGrowthCalculatorApp: App {
    private let featureAvailability: any FeatureAvailability = LocalFreeAvailability()
    private let scenarioStore: any ScenarioStore
    @StateObject private var preferences: AppPreferencesModel

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let configuration: ScenarioStoreConfiguration
        let uiIdentifier: String?
        if let marker = arguments.firstIndex(of: "-uiScenarioStore"),
           arguments.indices.contains(marker + 1) {
            let identifier = arguments[marker + 1]
                .filter { $0.isLetter || $0.isNumber || $0 == "-" }
            uiIdentifier = identifier.isEmpty ? "default" : identifier
            configuration = ScenarioStoreConfiguration(
                applicationSupportDirectoryComponents: [
                    "InvestmentGrowthCalculator",
                    "UITests",
                    uiIdentifier ?? "default",
                ]
            )
        } else {
            uiIdentifier = nil
            configuration = .applicationSupport
        }

        var failures = ScenarioStoreFailureInjection.none
        failures.unavailableOnRead = arguments.contains("-uiUnavailableStore")
        failures.corruptOnRead = arguments.contains("-uiCorruptStore")
        failures.unsupportedOnRead = arguments.contains("-uiUnsupportedStore")
        failures.eraseAllDataFailureAfterDocumentRemovalCount =
            arguments.contains("-uiScenarioEraseFailsOnce") ? 1 : 0
        scenarioStore = CodableScenarioStore(
            configuration: configuration,
            failures: failures
        )

        let defaults: UserDefaults
        if let uiIdentifier,
           let isolatedDefaults = UserDefaults(
               suiteName: "uk.co.mochadesigns.igc.uitests.\(uiIdentifier)"
           ) {
            defaults = isolatedDefaults
        } else {
            defaults = .standard
        }
        var preferenceFailures = AppPreferencesFailureInjection.none
        preferenceFailures.appearanceWriteFailure =
            arguments.contains("-uiAppearanceWriteFailure")
        preferenceFailures.coachWriteFailure =
            arguments.contains("-uiCoachWriteFailure")
        preferenceFailures.resetFailureAfterAppearanceRemovalCount =
            arguments.contains("-uiPreferenceResetFailsOnce") ? 1 : 0
        let preferenceStore = UserDefaultsAppPreferencesStore(
            defaults: defaults,
            failures: preferenceFailures
        )
        _preferences = StateObject(
            wrappedValue: AppPreferencesModel(store: preferenceStore)
        )
    }

    @ViewBuilder
    private var rootView: some View {
        let root = RootTabView(
            featureAvailability: featureAvailability,
            scenarioStore: scenarioStore,
            preferences: preferences
        )
        if ProcessInfo.processInfo.arguments.contains("-uiAccessibilityText") {
            root
                .environment(\.dynamicTypeSize, .accessibility3)
                .preferredColorScheme(preferences.appearance.colourScheme)
        } else {
            root.preferredColorScheme(preferences.appearance.colourScheme)
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }
}
