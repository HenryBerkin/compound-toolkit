import SwiftUI

@main
struct InvestmentGrowthCalculatorApp: App {
    private let featureAvailability: any FeatureAvailability = LocalFreeAvailability()

    var body: some Scene {
        WindowGroup {
            RootTabView(featureAvailability: featureAvailability)
        }
    }
}
