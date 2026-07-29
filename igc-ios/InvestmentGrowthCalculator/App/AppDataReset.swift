import Foundation

struct AppDataResetResult: Equatable, Sendable {
    let completed: Bool
    let message: String

    static let success = AppDataResetResult(
        completed: true,
        message: "All app data deleted"
    )
}

@MainActor
enum AppDataResetCoordinator {
    static func execute(
        scenarioLibrary: ScenarioLibraryModel,
        preferences: AppPreferencesModel
    ) async -> AppDataResetResult {
        var scenarioMutationFailed = false
        var preferenceMutationFailed = false

        do {
            try await scenarioLibrary.eraseAllData()
        } catch {
            scenarioMutationFailed = true
        }

        do {
            try preferences.resetPersistentPreferences()
        } catch {
            preferenceMutationFailed = true
        }

        await scenarioLibrary.refresh()
        preferences.reload()

        let scenariosVerifiedEmpty: Bool
        if case let .available(readable)? = scenarioLibrary.snapshot {
            scenariosVerifiedEmpty = readable.isEmpty
        } else {
            scenariosVerifiedEmpty = false
        }
        let preferencesVerifiedDefault = preferences.snapshot == .defaults

        guard !scenarioMutationFailed,
              !preferenceMutationFailed,
              scenariosVerifiedEmpty,
              preferencesVerifiedDefault else {
            var details: [String] = []
            if scenarioMutationFailed {
                details.append(scenarioFailureDetail(snapshot: scenarioLibrary.snapshot))
            } else if !scenariosVerifiedEmpty {
                details.append(scenarioVerificationDetail(snapshot: scenarioLibrary.snapshot))
            }
            if preferenceMutationFailed {
                details.append(preferenceFailureDetail(snapshot: preferences.snapshot))
            } else if !preferencesVerifiedDefault {
                details.append("App preferences are not at their defaults.")
            }
            if details.isEmpty {
                details.append("The persistent result could not be verified.")
            }
            return AppDataResetResult(
                completed: false,
                message: "Deletion did not complete. \(details.joined(separator: " ")) Try again."
            )
        }

        return .success
    }

    private static func scenarioFailureDetail(
        snapshot: ScenarioStoreSnapshot?
    ) -> String {
        switch snapshot {
        case let .available(readable):
            if readable.isEmpty {
                "Saved scenarios appear empty, but recovery-material erasure could not be verified."
            } else {
                "\(readable.scenarios.count) saved scenario\(readable.scenarios.count == 1 ? "" : "s") remain."
            }
        case .unavailable:
            "Saved scenarios and recovery material could not be verified."
        case .corrupt:
            "Unreadable saved-scenario data remains."
        case .unsupported:
            "Saved scenarios in a newer format remain."
        case nil:
            "Saved scenarios and recovery material could not be re-read."
        }
    }

    private static func scenarioVerificationDetail(
        snapshot: ScenarioStoreSnapshot?
    ) -> String {
        switch snapshot {
        case let .available(readable):
            "\(readable.scenarios.count) saved scenario\(readable.scenarios.count == 1 ? "" : "s") remain."
        case .unavailable:
            "Saved scenarios could not be verified."
        case .corrupt:
            "Unreadable saved-scenario data remains."
        case .unsupported:
            "Saved scenarios in a newer format remain."
        case nil:
            "Saved scenarios could not be re-read."
        }
    }

    private static func preferenceFailureDetail(
        snapshot: AppPreferenceSnapshot
    ) -> String {
        var remaining: [String] = []
        if snapshot.appearance != .system {
            remaining.append("appearance")
        }
        if snapshot.coachDismissed {
            remaining.append("the coach dismissal")
        }
        if remaining.isEmpty {
            return "App preferences appear to be at defaults, but their reset could not be verified."
        }
        return "The \(remaining.joined(separator: " and ")) preference remains."
    }
}
