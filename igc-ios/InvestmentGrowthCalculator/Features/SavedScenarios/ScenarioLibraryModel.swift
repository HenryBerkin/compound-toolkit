import Foundation
import SwiftUI

@MainActor
final class ScenarioLibraryModel: ObservableObject {
    @Published private(set) var snapshot: ScenarioStoreSnapshot?
    @Published private(set) var isLoading = true

    private let store: any ScenarioStore

    init(store: any ScenarioStore) {
        self.store = store
    }

    func refresh() async {
        isLoading = true
        snapshot = await store.snapshot()
        isLoading = false
    }

    func createNew(
        from projection: ProjectionSnapshot,
        proposedName: String,
        id: String = UUID().uuidString,
        date: Date = Date()
    ) async throws -> String {
        let scenario: ScenarioV1
        do {
            scenario = try ScenarioV1(
                id: id,
                name: proposedName,
                inputs: projection.input,
                presetID: projection.presetID,
                targetToday: projection.targetToday,
                createdAt: date,
                updatedAt: date
            )
        } catch {
            throw ScenarioStoreError.invalidScenario
        }

        do {
            let readable = try await store.create(scenario)
            snapshot = .available(readable)
            isLoading = false
            return scenario.name
        } catch {
            await refreshAfterFailedMutation()
            throw error
        }
    }

    func scenario(id: String) async throws -> ScenarioV1 {
        try await store.scenario(id: id)
    }

    func rename(
        id: String,
        proposedName: String,
        date: Date = Date()
    ) async throws -> String {
        let completedName: String
        do {
            completedName = try ScenarioNameValidator.normalized(proposedName)
        } catch {
            throw error
        }

        do {
            let readable = try await store.rename(
                id: id,
                name: completedName,
                at: date
            )
            snapshot = .available(readable)
            isLoading = false
            return completedName
        } catch {
            await refreshAfterFailedMutation()
            throw error
        }
    }

    func duplicate(
        id: String,
        newID: String = UUID().uuidString,
        date: Date = Date()
    ) async throws -> String {
        do {
            let readable = try await store.duplicate(id: id, newID: newID, at: date)
            snapshot = .available(readable)
            isLoading = false
            guard let duplicate = readable.scenario(id: newID) else {
                throw ScenarioStoreError.reloadFailed
            }
            return duplicate.name
        } catch {
            await refreshAfterFailedMutation()
            throw error
        }
    }

    func delete(id: String) async throws {
        do {
            let readable = try await store.delete(id: id)
            snapshot = .available(readable)
            isLoading = false
        } catch {
            await refreshAfterFailedMutation()
            throw error
        }
    }

    func resetAfterRecovery() async throws {
        do {
            let readable = try await store.resetAfterRecovery()
            snapshot = .available(readable)
            isLoading = false
        } catch {
            await refreshAfterFailedMutation()
            throw error
        }
    }

    private func refreshAfterFailedMutation() async {
        snapshot = await store.snapshot()
        isLoading = false
    }
}
