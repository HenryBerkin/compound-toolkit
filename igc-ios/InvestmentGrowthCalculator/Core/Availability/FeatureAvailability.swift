enum AppFeature: CaseIterable, Sendable {
    case calculator
    case scenarios
    case annualDetail
    case education
}
protocol FeatureAvailability: Sendable {
    func isAvailable(_ feature: AppFeature) -> Bool
}

struct LocalFreeAvailability: FeatureAvailability {
    func isAvailable(_ feature: AppFeature) -> Bool {
        true
    }
}
