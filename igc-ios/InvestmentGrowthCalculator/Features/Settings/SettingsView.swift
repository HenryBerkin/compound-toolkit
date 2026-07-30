import SwiftUI
import UIKit

struct SettingsView: View {
    @ObservedObject var preferences: AppPreferencesModel
    let deleteAllData: () async -> AppDataResetResult
    let bundle: Bundle

    @State private var showsDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deletionFailure: String?
    @AccessibilityFocusState private var deleteButtonFocused: Bool
    @AccessibilityFocusState private var failureFocused: Bool

    init(
        preferences: AppPreferencesModel,
        bundle: Bundle = .main,
        deleteAllData: @escaping () async -> AppDataResetResult
    ) {
        self.preferences = preferences
        self.bundle = bundle
        self.deleteAllData = deleteAllData
    }

    var body: some View {
        List {
            Section("Appearance") {
                Picker("Appearance", selection: appearanceBinding) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.title).tag(appearance)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.appearance")

                Text("System follows the device appearance. Light and Dark override it for IGC.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let message = preferences.message {
                    ScenarioStatusBanner(kind: .failure, message: message)
                        .accessibilityIdentifier("settings.preferenceFailure")
                }
            }

            Section("Data on this device") {
                Text("Saved scenarios are held in the app’s Application Support storage. Appearance and coach choices are held in app preferences. Normal device and system backups have their own lifecycle.")

                if let deletionFailure {
                    ScenarioStatusBanner(
                        kind: .failure,
                        message: deletionFailure,
                        retry: startDeletion
                    )
                    .accessibilityFocused($failureFocused)
                    .accessibilityIdentifier("settings.deleteFailure")
                }

                if isDeleting {
                    HStack {
                        ProgressView()
                        Text("Deleting app data…")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("settings.deleting")
                }

                Button("Delete all app data", role: .destructive) {
                    showsDeleteConfirmation = true
                }
                .disabled(isDeleting)
                .frame(minHeight: 44)
                .accessibilityFocused($deleteButtonFocused)
                .accessibilityIdentifier("settings.deleteAllData")
                .accessibilityHint("Asks for confirmation before deleting all saved scenarios and resetting app state.")
            }

            Section("About and help") {
                NavigationLink("About IGC", value: SettingsRoute.about)
                .accessibilityIdentifier("settings.about")

                NavigationLink("Privacy", value: SettingsRoute.privacy)
                .accessibilityIdentifier("settings.privacy")

                NavigationLink("Support", value: SettingsRoute.support)
                .accessibilityIdentifier("settings.support")

                NavigationLink(
                    "Projection disclaimer",
                    value: SettingsRoute.disclaimer
                )
                .accessibilityIdentifier("settings.disclaimer")
            }
        }
        .navigationTitle("Settings")
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .alert(
            "Delete all app data?",
            isPresented: $showsDeleteConfirmation
        ) {
            Button("Delete all app data", role: .destructive) {
                startDeletion()
            }
            .accessibilityIdentifier("settings.confirmDeleteAllData")
            Button("Cancel", role: .cancel) {
                restoreDeleteFocus()
            }
        } message: {
            Text("This deletes saved scenarios and resets appearance, onboarding, and calculator state on this device. This can’t be undone. Device backups have their own lifecycle.")
        }
    }

    private var appearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { preferences.appearance },
            set: { preferences.chooseAppearance($0) }
        )
    }

    private func startDeletion() {
        guard !isDeleting else { return }
        isDeleting = true
        deletionFailure = nil
        Task { @MainActor in
            let result = await deleteAllData()
            isDeleting = false
            if result.completed {
                UIAccessibility.post(
                    notification: .announcement,
                    argument: result.message
                )
            } else {
                deletionFailure = result.message
                await Task.yield()
                failureFocused = true
                UIAccessibility.post(
                    notification: .announcement,
                    argument: result.message
                )
            }
        }
    }

    private func restoreDeleteFocus() {
        Task { @MainActor in
            await Task.yield()
            deleteButtonFocused = true
        }
    }
}

struct AppVersionInfo: Equatable, Sendable {
    let version: String
    let build: String

    init(bundle: Bundle) {
        version = bundle.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "Not available"
        build = bundle.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "Not available"
    }

    var displayValue: String {
        "\(version) (\(build))"
    }
}

struct AboutIGCView: View {
    let bundle: Bundle

    private var versionInfo: AppVersionInfo {
        AppVersionInfo(bundle: bundle)
    }

    var body: some View {
        List {
            Section("Product") {
                LabeledContent("Name", value: "Investment Growth Calculator")
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("about.productName")
                LabeledContent("Shorthand", value: "IGC")
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("about.shorthand")
                LabeledContent("Version and build", value: versionInfo.displayValue)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("about.versionBuild")
            }
            Section("Purpose") {
                Text("IGC is a free, local educational calculator for exploring illustrative investment-growth projections in UK English and GBP.")
                Text("It does not connect to an account, execute a transaction or use live market data.")
            }
        }
        .navigationTitle("About IGC")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}

enum SupportDestination {
    static let email = "support@mochadesigns.co.uk"
    static let pageURL = URL(string: "https://igc.mochadesigns.co.uk/support")!
    static let emailURL = URL(string: "mailto:support@mochadesigns.co.uk")!
}

struct SupportView: View {
    var body: some View {
        List {
            Section("Getting help") {
                Text("IGC calculates on this device and has no account to recover, so most questions are about how the projection is built. Education covers the method, the glossary and what the projection excludes.")
                NavigationLink(
                    "How calculations work",
                    value: SettingsRoute.methodology
                )
                .frame(minHeight: 44)
                .accessibilityIdentifier("support.methodology")
            }

            Section("Contact") {
                Link(destination: SupportDestination.pageURL) {
                    LabeledContent("Support page", value: "igc.mochadesigns.co.uk/support")
                }
                .frame(minHeight: 44)
                .accessibilityIdentifier("support.page")
                .accessibilityLabel("Support page. Opens igc.mochadesigns.co.uk slash support in your browser.")

                Link(destination: SupportDestination.emailURL) {
                    LabeledContent("Email", value: SupportDestination.email)
                }
                .frame(minHeight: 44)
                .accessibilityIdentifier("support.email")
                .accessibilityLabel("Email support at mochadesigns.co.uk. Opens your mail app.")
            }

            Section {
                Text("These open your browser or mail app. IGC does not send anything on your behalf, and no scenario, balance or contribution is attached to a message you choose to write.")
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("settings.supportInformation")
    }
}

struct PrivacyInformationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                privacySection(
                    "Calculation",
                    "Calculation is performed inside the app. Values remain in Calculator state unless you deliberately save a scenario."
                )
                privacySection(
                    "Saved scenarios",
                    "Saved scenarios, including their names and assumptions, are held in the app’s Application Support storage. You can delete one scenario from Saved. If stored data cannot be read, IGC preserves recovery material where practical until you choose a recovery or deletion action."
                )
                privacySection(
                    "App preferences",
                    "Appearance and first-launch coach choices are held in app preferences. No scenario name, balance, contribution, target, rate or timestamp is stored there."
                )
                privacySection(
                    "Accounts, sync and backups",
                    "This implementation has no IGC account and no app-operated cross-device sync. Normal device and system backups have their own lifecycle, so deleting app data does not claim to remove an existing backup."
                )
                privacySection(
                    "Deletion",
                    "Delete all app data in Settings separately confirms removal of saved scenarios and app-owned recovery material, then resets appearance, onboarding and Calculator state. It reports success only after the app re-reads empty scenario storage and default preferences. If verification fails, IGC reports that deletion did not complete and offers Try again."
                )
                privacySection(
                    "Services not present",
                    "This implementation has no analytics, advertising, tracking, remote configuration, account connection, payment, live market data or support diagnostics."
                )
                privacySection(
                    "Support links",
                    "Support in Settings offers a web address and an email address. Choosing one hands over to your browser or mail app; IGC itself makes no network request and attaches no scenario, balance, contribution or diagnostic data to anything you then choose to send."
                )
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("settings.privacyInformation")
    }

    private func privacySection(_ heading: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(heading)
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            Text(body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
