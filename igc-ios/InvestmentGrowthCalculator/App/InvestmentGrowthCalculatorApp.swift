import SwiftUI

@main
struct InvestmentGrowthCalculatorApp: App {
    private let featureAvailability: any FeatureAvailability = LocalFreeAvailability()
    private let scenarioStore: any ScenarioStore

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let configuration: ScenarioStoreConfiguration
        if let marker = arguments.firstIndex(of: "-uiScenarioStore"),
           arguments.indices.contains(marker + 1) {
            let identifier = arguments[marker + 1]
                .filter { $0.isLetter || $0.isNumber || $0 == "-" }
            configuration = ScenarioStoreConfiguration(
                applicationSupportDirectoryComponents: [
                    "InvestmentGrowthCalculator",
                    "UITests",
                    identifier.isEmpty ? "default" : identifier,
                ]
            )
        } else {
            configuration = .applicationSupport
        }

        var failures = ScenarioStoreFailureInjection.none
        failures.unavailableOnRead = arguments.contains("-uiUnavailableStore")
        failures.corruptOnRead = arguments.contains("-uiCorruptStore")
        failures.unsupportedOnRead = arguments.contains("-uiUnsupportedStore")
        scenarioStore = CodableScenarioStore(
            configuration: configuration,
            failures: failures
        )
    }

    @ViewBuilder
    private var rootView: some View {
        let root = RootTabView(
            featureAvailability: featureAvailability,
            scenarioStore: scenarioStore
        )
        if ProcessInfo.processInfo.arguments.contains("-uiAccessibilityText") {
            root.environment(\.dynamicTypeSize, .accessibility3)
        } else {
            root
        }
    }

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }
}
