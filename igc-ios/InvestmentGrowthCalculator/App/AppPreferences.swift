import Foundation
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colourScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct AppPreferenceSnapshot: Equatable, Sendable {
    let appearance: AppAppearance
    let coachDismissed: Bool

    static let defaults = AppPreferenceSnapshot(
        appearance: .system,
        coachDismissed: false
    )
}

enum AppPreferenceError: Error, Equatable, LocalizedError, Sendable {
    case appearanceWriteFailed
    case coachWriteFailed
    case resetFailed
    case verificationFailed

    var errorDescription: String? {
        switch self {
        case .appearanceWriteFailed:
            "The appearance preference could not be saved."
        case .coachWriteFailed:
            "The coach preference could not be saved."
        case .resetFailed:
            "The app preferences could not be reset."
        case .verificationFailed:
            "The app preferences could not be verified."
        }
    }
}

@MainActor
protocol AppPreferencesStore: AnyObject {
    func load() -> AppPreferenceSnapshot
    func setAppearance(_ appearance: AppAppearance) throws -> AppPreferenceSnapshot
    func dismissCoach() throws -> AppPreferenceSnapshot
    func reset() throws -> AppPreferenceSnapshot
}

struct AppPreferencesFailureInjection {
    var appearanceWriteFailure = false
    var coachWriteFailure = false
    var resetFailureBeforeMutation = false
    var resetFailureAfterAppearanceRemovalCount = 0

    static let none = AppPreferencesFailureInjection()
}

@MainActor
final class UserDefaultsAppPreferencesStore: AppPreferencesStore {
    static let appearanceKey = "igc.appearance.v1"
    static let coachDismissedKey = "igc.coach.dismissed.v1"
    static let ownedKeys = Set([appearanceKey, coachDismissedKey])

    private let defaults: UserDefaults
    private var failures: AppPreferencesFailureInjection

    init(
        defaults: UserDefaults = .standard,
        failures: AppPreferencesFailureInjection = .none
    ) {
        self.defaults = defaults
        self.failures = failures
    }

    func load() -> AppPreferenceSnapshot {
        let appearance = defaults.string(forKey: Self.appearanceKey)
            .flatMap(AppAppearance.init(rawValue:)) ?? .system
        let coachDismissed = defaults.object(forKey: Self.coachDismissedKey) as? Bool ?? false
        return AppPreferenceSnapshot(
            appearance: appearance,
            coachDismissed: coachDismissed
        )
    }

    func setAppearance(_ appearance: AppAppearance) throws -> AppPreferenceSnapshot {
        guard !failures.appearanceWriteFailure else {
            throw AppPreferenceError.appearanceWriteFailed
        }
        defaults.set(appearance.rawValue, forKey: Self.appearanceKey)
        let snapshot = load()
        guard defaults.string(forKey: Self.appearanceKey) == appearance.rawValue,
              snapshot.appearance == appearance else {
            throw AppPreferenceError.verificationFailed
        }
        return snapshot
    }

    func dismissCoach() throws -> AppPreferenceSnapshot {
        guard !failures.coachWriteFailure else {
            throw AppPreferenceError.coachWriteFailed
        }
        defaults.set(true, forKey: Self.coachDismissedKey)
        let snapshot = load()
        guard defaults.object(forKey: Self.coachDismissedKey) as? Bool == true,
              snapshot.coachDismissed else {
            throw AppPreferenceError.verificationFailed
        }
        return snapshot
    }

    func reset() throws -> AppPreferenceSnapshot {
        guard !failures.resetFailureBeforeMutation else {
            throw AppPreferenceError.resetFailed
        }

        defaults.removeObject(forKey: Self.appearanceKey)
        if failures.resetFailureAfterAppearanceRemovalCount > 0 {
            failures.resetFailureAfterAppearanceRemovalCount -= 1
            throw AppPreferenceError.resetFailed
        }
        defaults.removeObject(forKey: Self.coachDismissedKey)

        let snapshot = load()
        guard snapshot == .defaults,
              defaults.object(forKey: Self.appearanceKey) == nil,
              defaults.object(forKey: Self.coachDismissedKey) == nil else {
            throw AppPreferenceError.verificationFailed
        }
        return snapshot
    }
}

@MainActor
final class AppPreferencesModel: ObservableObject {
    @Published private(set) var appearance: AppAppearance
    @Published private(set) var coachDismissed: Bool
    @Published private(set) var sessionCoachDismissed = false
    @Published private(set) var message: String?

    private let store: any AppPreferencesStore

    init(store: any AppPreferencesStore) {
        self.store = store
        let snapshot = store.load()
        appearance = snapshot.appearance
        coachDismissed = snapshot.coachDismissed
    }

    var showsCoach: Bool {
        !coachDismissed && !sessionCoachDismissed
    }

    var snapshot: AppPreferenceSnapshot {
        AppPreferenceSnapshot(
            appearance: appearance,
            coachDismissed: coachDismissed
        )
    }

    func chooseAppearance(_ selection: AppAppearance) {
        appearance = selection
        do {
            apply(try store.setAppearance(selection))
            message = nil
        } catch {
            message = "Appearance changed for this session, but the preference was not saved."
        }
    }

    func dismissCoach() {
        sessionCoachDismissed = true
        do {
            apply(try store.dismissCoach())
            message = nil
        } catch {
            message = "The coach was dismissed for this session, but the preference was not saved."
        }
    }

    func reload() {
        apply(store.load())
    }

    func resetPersistentPreferences() throws {
        let resetSnapshot = try store.reset()
        guard resetSnapshot == .defaults else {
            throw AppPreferenceError.verificationFailed
        }
        let reread = store.load()
        guard reread == .defaults else {
            throw AppPreferenceError.verificationFailed
        }
        apply(reread)
        sessionCoachDismissed = false
        message = nil
    }

    func clearMessage() {
        message = nil
    }

    private func apply(_ snapshot: AppPreferenceSnapshot) {
        appearance = snapshot.appearance
        coachDismissed = snapshot.coachDismissed
    }
}
