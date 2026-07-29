import SwiftUI

struct ScenarioNameEntryView: View {
    let title: String
    let initialName: String
    let actionLabel: String
    let accessibilityPrefix: String
    let submit: @MainActor (String) async throws -> String
    let onSuccess: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var validationMessage: String?
    @State private var persistenceMessage: String?
    @State private var isSubmitting = false

    init(
        title: String,
        initialName: String,
        actionLabel: String,
        accessibilityPrefix: String,
        submit: @escaping @MainActor (String) async throws -> String,
        onSuccess: @escaping (String) -> Void
    ) {
        self.title = title
        self.initialName = initialName
        self.actionLabel = actionLabel
        self.accessibilityPrefix = accessibilityPrefix
        self.submit = submit
        self.onSuccess = onSuccess
        _name = State(initialValue: initialName)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Scenario name", text: $name)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.done)
                        .onSubmit(beginSubmit)
                        .accessibilityIdentifier("\(accessibilityPrefix).name")

                    if let validationMessage {
                        Label(
                            validationMessage,
                            systemImage: "exclamationmark.circle.fill"
                        )
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("\(accessibilityPrefix).nameError")
                    }
                } footer: {
                    Text("Names are trimmed and can contain up to 120 portable characters.")
                }

                if let persistenceMessage {
                    Section {
                        Label(
                            persistenceMessage,
                            systemImage: "exclamationmark.triangle.fill"
                        )
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("\(accessibilityPrefix).persistenceError")

                        Button("Try again", action: beginSubmit)
                            .disabled(isSubmitting)
                            .accessibilityIdentifier("\(accessibilityPrefix).tryAgain")
                    }
                }

                if isSubmitting {
                    Section {
                        ProgressView("Saving changes")
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(actionLabel, action: beginSubmit)
                        .disabled(isSubmitting || persistenceMessage != nil)
                        .accessibilityIdentifier("\(accessibilityPrefix).confirm")
                }
            }
            .onChange(of: name) {
                validationMessage = nil
            }
        }
    }

    private func beginSubmit() {
        guard !isSubmitting else { return }
        let completedName: String
        do {
            completedName = try ScenarioNameValidator.normalized(name)
        } catch {
            validationMessage = error.localizedDescription
            return
        }

        name = completedName
        validationMessage = nil
        persistenceMessage = nil
        isSubmitting = true
        Task { @MainActor in
            do {
                let persistedName = try await submit(completedName)
                isSubmitting = false
                onSuccess(persistedName)
                dismiss()
            } catch {
                isSubmitting = false
                persistenceMessage = persistenceFailureMessage(error)
            }
        }
    }

    private func persistenceFailureMessage(_ error: Error) -> String {
        guard let storeError = error as? ScenarioStoreError else {
            return "The change couldn’t be saved. No success was reported."
        }
        switch storeError {
        case .unavailable:
            return "Saved scenarios are temporarily unavailable. Try again when storage is accessible."
        case .corrupt:
            return "Saved scenarios need recovery in Saved. The source document was not replaced."
        case .unsupported:
            return "Saved scenarios use a newer format. The source document was not replaced."
        case .temporaryWriteFailed:
            return "The temporary document couldn’t be written. The previous readable document was kept."
        case .replacementFailed:
            return "The previous document couldn’t be replaced, so it was kept."
        case .reloadFailed:
            return "The saved document couldn’t be verified after the change. No success was reported."
        case .notFound:
            return "The saved scenario no longer exists."
        case .invalidScenario, .duplicateID,
             .recoveryPreservationFailed, .recoveryResetNotRequired,
             .eraseAllDataFailed, .eraseAllDataIncomplete:
            return "The change couldn’t be saved. No success was reported."
        }
    }
}
