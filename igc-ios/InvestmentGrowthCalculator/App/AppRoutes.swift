import Foundation

enum AppTab: Hashable {
    case calculator
    case saved
    case education
    case settings
}

struct LoadedScenarioContext: Equatable, Sendable {
    let id: String
    let name: String
    let input: CalculationInput
    let targetToday: Double?
    let draftAtLoad: CalculatorDraft
}

enum CalculatorRoute: Hashable {
    case projection(ProjectionSnapshot)
    case annualDetail(ProjectionSnapshot)
    case education(EducationArticle)

    static func == (lhs: CalculatorRoute, rhs: CalculatorRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.projection(lhsSnapshot), .projection(rhsSnapshot)),
             let (.annualDetail(lhsSnapshot), .annualDetail(rhsSnapshot)):
            lhsSnapshot.id == rhsSnapshot.id
        case let (.education(lhsArticle), .education(rhsArticle)):
            lhsArticle == rhsArticle
        default:
            false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .projection(snapshot):
            hasher.combine(0)
            hasher.combine(snapshot.id)
        case let .annualDetail(snapshot):
            hasher.combine(1)
            hasher.combine(snapshot.id)
        case let .education(article):
            hasher.combine(2)
            hasher.combine(article)
        }
    }
}

enum SavedRoute: Hashable {
    case calculator
}

enum EducationRoute: Hashable {
    case article(EducationArticle)
    case glossary
    case glossaryTerm(GlossaryTerm)
}

enum SettingsRoute: Hashable {
    case about
    case privacy
    case disclaimer
}
