import SwiftUI

struct RootTabView: View {
    let featureAvailability: any FeatureAvailability

    @State private var selectedTab: AppTab = .calculator
    @State private var calculatorPath: [CalculatorRoute] = []
    @State private var savedPath: [SavedRoute] = []
    @State private var educationPath: [EducationRoute] = []
    @State private var settingsPath: [SettingsRoute] = []
    @State private var draft: CalculatorDraft

    init(featureAvailability: any FeatureAvailability) {
        self.featureAvailability = featureAvailability
        var initialDraft = CalculatorDraft.customBaseline
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiInvalidBaseline") {
            initialDraft.principal = "0"
            initialDraft.contribution = "0"
        }
        if arguments.contains("-uiTargetBaseline") {
            initialDraft.targetIsExpanded = true
            initialDraft.target = "100000"
        }
        _draft = State(initialValue: initialDraft)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $calculatorPath) {
                CalculatorView(draft: $draft) { newSnapshot in
                    calculatorPath = [.projection(newSnapshot)]
                }
                .navigationDestination(for: CalculatorRoute.self) { route in
                    switch route {
                    case let .projection(snapshot):
                        ProjectionView(snapshot: snapshot) {
                            calculatorPath.append(.annualDetail(snapshot))
                        }
                    case let .annualDetail(snapshot):
                        AnnualDetailView(snapshot: snapshot)
                    }
                }
            }
            .tabItem {
                Label("Calculator", systemImage: "function")
            }
            .tag(AppTab.calculator)
            .accessibilityIdentifier("tab.calculator")

            NavigationStack(path: $savedPath) {
                SavedScenariosView {
                    savedPath.removeAll()
                    calculatorPath.removeAll()
                    selectedTab = .calculator
                }
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark")
            }
            .tag(AppTab.saved)
            .accessibilityIdentifier("tab.saved")

            NavigationStack(path: $educationPath) {
                EducationView()
            }
            .tabItem {
                Label("Education", systemImage: "book.closed")
            }
            .tag(AppTab.education)
            .accessibilityIdentifier("tab.education")

            NavigationStack(path: $settingsPath) {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings)
            .accessibilityIdentifier("tab.settings")
        }
        .tint(.indigo)
    }
}
