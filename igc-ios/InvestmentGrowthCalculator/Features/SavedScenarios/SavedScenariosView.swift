import SwiftUI

struct SavedScenariosView: View {
    @ObservedObject var scenarioLibrary: ScenarioLibraryModel
    let loadScenario: @MainActor (String) async throws -> Void
    let goToCalculator: () -> Void

    @State private var renameTarget: ScenarioV1?
    @State private var deleteTarget: ScenarioV1?
    @State private var actionStatus: ActionStatus?
    @State private var pendingIDs: Set<String> = []
    @State private var showsRecoveryResetConfirmation = false
    @State private var recoveryResetKind: RecoveryResetKind = .corrupt

    var body: some View {
        Group {
            if scenarioLibrary.isLoading || scenarioLibrary.snapshot == nil {
                ProgressView("Loading saved scenarios")
                    .accessibilityIdentifier("saved.loading")
            } else {
                switch scenarioLibrary.snapshot {
                case let .available(readable):
                    availableContent(readable)
                case .unavailable:
                    unavailableContent
                case let .corrupt(evidence):
                    corruptContent(evidence)
                case let .unsupported(_, evidence):
                    unsupportedContent(evidence)
                case nil:
                    EmptyView()
                }
            }
        }
        .navigationTitle("Saved scenarios")
        .sheet(item: $renameTarget) { scenario in
            ScenarioNameEntryView(
                title: "Rename scenario",
                initialName: scenario.name,
                actionLabel: "Rename",
                accessibilityPrefix: "saved.rename",
                submit: { proposedName in
                    try await scenarioLibrary.rename(
                        id: scenario.id,
                        proposedName: proposedName
                    )
                },
                onSuccess: { name in
                    actionStatus = .success("Renamed to “\(name)”")
                }
            )
        }
        .alert(
            deleteTarget.map { "Delete “\($0.name)”?" } ?? "Delete scenario?",
            isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }
            ),
            presenting: deleteTarget
        ) { scenario in
            Button("Delete scenario", role: .destructive) {
                deleteTarget = nil
                performDelete(id: scenario.id, name: scenario.name)
            }
            .accessibilityIdentifier("saved.confirmDelete")
            Button("Cancel", role: .cancel) {
                deleteTarget = nil
            }
        } message: { _ in
            Text("This removes the saved scenario from this device. This can’t be undone.")
        }
        .alert(
            recoveryResetKind.title,
            isPresented: $showsRecoveryResetConfirmation
        ) {
            Button(recoveryResetKind.actionLabel, role: .destructive) {
                performRecoveryReset()
            }
            .accessibilityIdentifier("saved.confirmRecoveryReset")
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(recoveryResetKind.message)
        }
    }

    @ViewBuilder
    private func availableContent(_ readable: ReadableScenarioSnapshot) -> some View {
        if readable.isEmpty {
            ScrollView {
                VStack(spacing: 16) {
                    if let actionStatus {
                        statusBanner(actionStatus)
                    }
                    ContentUnavailableView {
                        Label("No saved scenarios", systemImage: "bookmark")
                    } description: {
                        Text("View a projection, then choose Save.")
                    } actions: {
                        Button("Go to Calculator", action: goToCalculator)
                            .buttonStyle(.borderedProminent)
                            .frame(minHeight: 44)
                            .accessibilityIdentifier("saved.goToCalculator")
                    }
                    storageFooter
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("saved.empty")
            }
        } else {
            List {
                if let actionStatus {
                    Section {
                        statusBanner(actionStatus)
                    }
                }

                Section {
                    Text(
                        "\(readable.scenarios.count) saved "
                            + (readable.scenarios.count == 1 ? "scenario" : "scenarios")
                    )
                    .font(.headline)
                    .accessibilityIdentifier("saved.count")
                }

                Section("Saved scenarios") {
                    ForEach(readable.scenarios) { scenario in
                        scenarioRow(scenario)
                    }
                }

                Section {
                    storageFooter
                }
            }
            .frame(maxWidth: 840)
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("saved.populated")
        }
    }

    private func scenarioRow(_ scenario: ScenarioV1) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
                performLoad(id: scenario.id, name: scenario.name)
            } label: {
                ScenarioRowContent(scenario: scenario)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(pendingIDs.contains(scenario.id))
            .accessibilityLabel(voiceOverLabel(for: scenario))
            .accessibilityHint("Loads into Calculator.")
            .accessibilityIdentifier("saved.row.\(scenario.id)")
            .accessibilityAction(named: "Rename") {
                renameTarget = scenario
            }
            .accessibilityAction(named: "Duplicate") {
                performDuplicate(id: scenario.id, name: scenario.name)
            }
            .accessibilityAction(named: "Delete") {
                deleteTarget = scenario
            }

            Menu {
                Button("Load") {
                    performLoad(id: scenario.id, name: scenario.name)
                }
                Button("Rename") {
                    renameTarget = scenario
                }
                Button("Duplicate") {
                    performDuplicate(id: scenario.id, name: scenario.name)
                }
                Button("Delete", role: .destructive) {
                    deleteTarget = scenario
                }
            } label: {
                Label("Actions for \(scenario.name)", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Actions for \(scenario.name)")
            .accessibilityIdentifier("saved.menu.\(scenario.id)")
            .disabled(pendingIDs.contains(scenario.id))
        }
    }

    private var unavailableContent: some View {
        recoveryContent(
            identifier: "saved.recovery.unavailable",
            symbol: "exclamationmark.triangle",
            heading: "Saved scenarios are temporarily unavailable",
            explanation: "The calculator still works, but scenarios can’t be loaded or saved right now.",
            evidenceText: nil,
            primaryTitle: "Try again",
            primaryAction: refresh,
            continueTitle: "Continue with calculator",
            destructiveTitle: nil,
            destructiveAction: nil
        )
    }

    private func corruptContent(_ evidence: ScenarioRecoveryEvidence) -> some View {
        recoveryContent(
            identifier: "saved.recovery.corrupt",
            symbol: "wrench.and.screwdriver",
            heading: "Saved scenarios need recovery",
            explanation: "The app could not read the saved data. It has not treated the document as an empty list.",
            evidenceText: evidence.sourcePreserved
                ? "A recovery copy was retained."
                : "The original document remains untouched, but a separate recovery copy could not be made.",
            primaryTitle: "Try again",
            primaryAction: refresh,
            continueTitle: "Continue without saved scenarios",
            destructiveTitle: "Start with an empty saved list",
            destructiveAction: {
                recoveryResetKind = .corrupt
                showsRecoveryResetConfirmation = true
            }
        )
    }

    private func unsupportedContent(_ evidence: ScenarioRecoveryEvidence) -> some View {
        recoveryContent(
            identifier: "saved.recovery.unsupported",
            symbol: "doc.badge.ellipsis",
            heading: "Saved scenarios use a newer format",
            explanation: "This version of the app cannot open them. No scenario was partially loaded.",
            evidenceText: evidence.sourcePreserved
                ? "A recovery copy was retained."
                : "The original document remains untouched, but a separate recovery copy could not be made.",
            primaryTitle: "Keep data and continue",
            primaryAction: goToCalculator,
            continueTitle: nil,
            destructiveTitle: "Delete saved scenarios",
            destructiveAction: {
                recoveryResetKind = .unsupported
                showsRecoveryResetConfirmation = true
            }
        )
    }

    private func recoveryContent(
        identifier: String,
        symbol: String,
        heading: String,
        explanation: String,
        evidenceText: String?,
        primaryTitle: String,
        primaryAction: @escaping () -> Void,
        continueTitle: String?,
        destructiveTitle: String?,
        destructiveAction: (() -> Void)?
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(heading, systemImage: symbol)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(explanation)
                if let evidenceText {
                    Text(evidenceText)
                        .foregroundStyle(.secondary)
                }
                if let actionStatus {
                    statusBanner(actionStatus)
                }
                Button(primaryTitle, action: primaryAction)
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)
                if let continueTitle {
                    Button(continueTitle, action: goToCalculator)
                        .buttonStyle(.bordered)
                        .frame(minHeight: 44)
                }
                if let destructiveTitle, let destructiveAction {
                    Button(destructiveTitle, role: .destructive, action: destructiveAction)
                        .frame(minHeight: 44)
                }
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .accessibilityIdentifier(identifier)
    }

    private var storageFooter: some View {
        Text(
            "Saved scenarios are held locally in this app’s protected "
                + "Application Support area. The app does not operate sync; "
                + "normal system backups may have their own lifecycle."
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .accessibilityIdentifier("saved.storageFooter")
    }

    private func statusBanner(_ status: ActionStatus) -> some View {
        ScenarioStatusBanner(
            kind: status.isSuccess ? .success : .failure,
            message: status.message,
            retry: status.retry.map { retry in
                { performRetry(retry) }
            }
        )
        .accessibilityIdentifier(status.isSuccess ? "saved.status.success" : "saved.status.failure")
    }

    private func refresh() {
        Task { @MainActor in
            await scenarioLibrary.refresh()
        }
    }

    private func performLoad(id: String, name: String) {
        pendingIDs.insert(id)
        Task { @MainActor in
            do {
                try await loadScenario(id)
                pendingIDs.remove(id)
            } catch {
                pendingIDs.remove(id)
                actionStatus = .failure(
                    "Couldn’t load “\(name)”",
                    retry: .load(id: id, name: name)
                )
            }
        }
    }

    private func performDuplicate(id: String, name: String) {
        pendingIDs.insert(id)
        Task { @MainActor in
            do {
                let duplicateName = try await scenarioLibrary.duplicate(id: id)
                pendingIDs.remove(id)
                actionStatus = .success("Created “\(duplicateName)”")
            } catch {
                pendingIDs.remove(id)
                actionStatus = .failure(
                    "Couldn’t duplicate “\(name)”",
                    retry: .duplicate(id: id, name: name)
                )
            }
        }
    }

    private func performDelete(id: String, name: String) {
        pendingIDs.insert(id)
        Task { @MainActor in
            do {
                try await scenarioLibrary.delete(id: id)
                pendingIDs.remove(id)
                actionStatus = .success("Deleted “\(name)”")
            } catch {
                pendingIDs.remove(id)
                actionStatus = .failure(
                    "Couldn’t delete “\(name)”",
                    retry: .delete(id: id, name: name)
                )
            }
        }
    }

    private func performRetry(_ retry: RetryAction) {
        switch retry {
        case let .load(id, name):
            performLoad(id: id, name: name)
        case let .duplicate(id, name):
            performDuplicate(id: id, name: name)
        case let .delete(id, name):
            performDelete(id: id, name: name)
        }
    }

    private func performRecoveryReset() {
        Task { @MainActor in
            do {
                try await scenarioLibrary.resetAfterRecovery()
                actionStatus = .success("Saved list is empty")
            } catch {
                actionStatus = .failure(
                    "Couldn’t replace the recovery document",
                    retry: nil
                )
            }
        }
    }

    private func voiceOverLabel(for scenario: ScenarioV1) -> String {
        let truthfulPreset = PresetCatalog.truthfulSelection(
            persisted: scenario.presetID,
            candidate: scenario.inputs.candidate
        )
        let preset = truthfulPreset.map {
            PresetCatalog.preset($0).name
        } ?? "Custom"
        return [
            scenario.name,
            preset,
            "Starting balance \(IGCFormatters.gbp(scenario.inputs.principal))",
            "Contribution \(IGCFormatters.gbp(scenario.inputs.contribution)) \(scenario.inputs.contributionFrequency.title)",
            "Growth rate \(IGCFormatters.percent(scenario.inputs.apr))",
            IGCFormatters.duration(years: scenario.inputs.years, months: scenario.inputs.months),
            "Updated \(scenario.updatedAt.formatted(date: .abbreviated, time: .shortened))",
        ].joined(separator: ", ")
    }
}

private struct ScenarioRowContent: View {
    let scenario: ScenarioV1

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(scenario.name)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
            Text(presetName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            LabeledContent(
                "Starting balance",
                value: IGCFormatters.gbp(scenario.inputs.principal)
            )
            .font(.subheadline)
            LabeledContent(
                "Contribution",
                value: "\(IGCFormatters.gbp(scenario.inputs.contribution)) \(scenario.inputs.contributionFrequency.title.lowercased())"
            )
            .font(.subheadline)
            LabeledContent(
                "Growth",
                value: IGCFormatters.percent(scenario.inputs.apr)
            )
            .font(.subheadline)
            LabeledContent(
                "Duration",
                value: IGCFormatters.duration(
                    years: scenario.inputs.years,
                    months: scenario.inputs.months
                )
            )
            .font(.subheadline)
            Text("Updated \(scenario.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var presetName: String {
        PresetCatalog.truthfulSelection(
            persisted: scenario.presetID,
            candidate: scenario.inputs.candidate
        ).map { PresetCatalog.preset($0).name } ?? "Custom"
    }
}

private struct ActionStatus {
    let message: String
    let retry: RetryAction?
    let isSuccess: Bool

    static func success(_ message: String) -> ActionStatus {
        ActionStatus(message: message, retry: nil, isSuccess: true)
    }

    static func failure(_ message: String, retry: RetryAction?) -> ActionStatus {
        ActionStatus(message: message, retry: retry, isSuccess: false)
    }
}

private enum RetryAction {
    case load(id: String, name: String)
    case duplicate(id: String, name: String)
    case delete(id: String, name: String)
}

private enum RecoveryResetKind {
    case corrupt
    case unsupported

    var title: String {
        switch self {
        case .corrupt: "Start with an empty saved list?"
        case .unsupported: "Delete saved scenarios?"
        }
    }

    var actionLabel: String {
        switch self {
        case .corrupt: "Start with empty list"
        case .unsupported: "Delete saved scenarios"
        }
    }

    var message: String {
        "The unreadable source must be preserved first. This action then replaces only "
            + "the saved-scenario store and can’t be undone."
    }
}
