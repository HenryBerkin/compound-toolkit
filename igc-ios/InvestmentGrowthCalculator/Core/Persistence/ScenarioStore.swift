import Foundation

struct ReadableScenarioSnapshot: Equatable, Sendable {
    let scenarios: [ScenarioV1]

    init(scenarios: [ScenarioV1]) {
        self.scenarios = ScenarioOrdering.sorted(scenarios)
    }

    var isEmpty: Bool { scenarios.isEmpty }

    func scenario(id: String) -> ScenarioV1? {
        scenarios.first(where: { $0.id == id })
    }
}

struct ScenarioRecoveryEvidence: Equatable, Sendable {
    let sourcePreserved: Bool
}

struct UnsupportedScenarioStore: Equatable, Sendable {
    let storeVersion: Int?
    let scenarioVersion: Int?
}

enum ScenarioStoreSnapshot: Equatable, Sendable {
    case available(ReadableScenarioSnapshot)
    case unavailable
    case corrupt(ScenarioRecoveryEvidence)
    case unsupported(UnsupportedScenarioStore, ScenarioRecoveryEvidence)
}

enum ScenarioStoreError: Error, Equatable, LocalizedError, Sendable {
    case unavailable
    case corrupt
    case unsupported
    case invalidScenario
    case duplicateID
    case notFound
    case temporaryWriteFailed
    case replacementFailed
    case reloadFailed
    case recoveryPreservationFailed
    case recoveryResetNotRequired
    case eraseAllDataFailed
    case eraseAllDataIncomplete

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Saved scenarios are temporarily unavailable."
        case .corrupt:
            "The saved-scenario document could not be read."
        case .unsupported:
            "The saved scenarios use an unsupported format."
        case .invalidScenario:
            "The scenario is not valid."
        case .duplicateID:
            "The scenario identifier is already in use."
        case .notFound:
            "The saved scenario no longer exists."
        case .temporaryWriteFailed:
            "The temporary saved-scenario document could not be written."
        case .replacementFailed:
            "The previous saved-scenario document could not be replaced."
        case .reloadFailed:
            "The saved-scenario document could not be verified after the change."
        case .recoveryPreservationFailed:
            "The recovery evidence could not be preserved, so the saved data was not replaced."
        case .recoveryResetNotRequired:
            "The saved-scenario document does not require recovery."
        case .eraseAllDataFailed:
            "The saved scenarios and recovery material could not be deleted."
        case .eraseAllDataIncomplete:
            "Deletion stopped before all saved-scenario data could be verified absent."
        }
    }
}

protocol ScenarioStore: Sendable {
    func snapshot() async -> ScenarioStoreSnapshot
    func scenario(id: String) async throws -> ScenarioV1
    func create(_ scenario: ScenarioV1) async throws -> ReadableScenarioSnapshot
    func rename(id: String, name: String, at date: Date) async throws -> ReadableScenarioSnapshot
    func duplicate(
        id: String,
        newID: String,
        at date: Date
    ) async throws -> ReadableScenarioSnapshot
    func delete(id: String) async throws -> ReadableScenarioSnapshot
    func resetAfterRecovery() async throws -> ReadableScenarioSnapshot
    func eraseAllData() async throws -> ReadableScenarioSnapshot
}

struct ScenarioStoreConfiguration: Sendable {
    static let productionDirectoryComponents = [
        "InvestmentGrowthCalculator",
        "SavedScenarios",
    ]
    static let documentFilename = "scenarios-v1.store.json"
    static let envelopeVersion = 1
    static let dataProtectionClass = FileProtectionType.complete

    let directoryURL: URL?
    let applicationSupportDirectoryComponents: [String]

    static let applicationSupport = ScenarioStoreConfiguration(
        directoryURL: nil,
        applicationSupportDirectoryComponents: productionDirectoryComponents
    )

    init(directoryURL: URL) {
        self.directoryURL = directoryURL
        self.applicationSupportDirectoryComponents = []
    }

    init(applicationSupportDirectoryComponents: [String]) {
        self.directoryURL = nil
        self.applicationSupportDirectoryComponents = applicationSupportDirectoryComponents
    }

    private init(
        directoryURL: URL?,
        applicationSupportDirectoryComponents: [String]
    ) {
        self.directoryURL = directoryURL
        self.applicationSupportDirectoryComponents = applicationSupportDirectoryComponents
    }
}

struct ScenarioStoreFailureInjection: Sendable {
    var unavailableOnRead = false
    var corruptOnRead = false
    var unsupportedOnRead = false
    var temporaryWriteFailure = false
    var replacementFailure = false
    var reloadAfterMutationFailure = false
    var recoveryCopyFailure = false
    var recoveryCopyFailureAfterSuccessfulCopies: Int?
    var eraseAllDataFailureBeforeMutation = false
    var eraseAllDataFailureAfterDocumentRemovalCount = 0

    static let none = ScenarioStoreFailureInjection()
}
