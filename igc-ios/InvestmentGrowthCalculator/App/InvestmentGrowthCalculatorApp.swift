import SwiftUI

@main
struct InvestmentGrowthCalculatorApp: App {
    private let featureAvailability: any FeatureAvailability = LocalFreeAvailability()

    @ViewBuilder
    private var rootView: some View {
        let root = RootTabView(featureAvailability: featureAvailability)
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
