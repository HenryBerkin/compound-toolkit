import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("About") {
                LabeledContent("App", value: "Investment Growth Calculator")
                LabeledContent("Shorthand", value: "IGC")
                LabeledContent("Version", value: appVersion)
            }
            Section("Current slice") {
                Text("Calculations use local in-memory state. Saved-scenario storage is not part of this delivery.")
            }
        }
        .navigationTitle("Settings")
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
