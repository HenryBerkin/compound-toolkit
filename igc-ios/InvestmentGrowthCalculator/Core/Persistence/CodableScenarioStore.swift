import Foundation

actor CodableScenarioStore: ScenarioStore {
    private let configuration: ScenarioStoreConfiguration
    private let failures: ScenarioStoreFailureInjection
    private let fileManager: FileManager
    private var successfulRecoveryCopyCount = 0

    init(
        configuration: ScenarioStoreConfiguration = .applicationSupport,
        failures: ScenarioStoreFailureInjection = .none,
        fileManager: FileManager = .default
    ) {
        self.configuration = configuration
        self.failures = failures
        self.fileManager = fileManager
    }

    func snapshot() async -> ScenarioStoreSnapshot {
        do {
            return .available(try readSnapshot())
        } catch let failure as DocumentReadFailure {
            switch failure {
            case .unavailable:
                return .unavailable
            case .corrupt:
                return .corrupt(preserveRecoveryEvidence())
            case let .unsupported(versions):
                return .unsupported(versions, preserveRecoveryEvidence())
            }
        } catch {
            return .unavailable
        }
    }

    func scenario(id: String) async throws -> ScenarioV1 {
        let readable = try readableSnapshotForMutation()
        guard let scenario = readable.scenario(id: id) else {
            throw ScenarioStoreError.notFound
        }
        try ScenarioValidator.validate(scenario)
        return scenario
    }

    func create(_ scenario: ScenarioV1) async throws -> ReadableScenarioSnapshot {
        do {
            try ScenarioValidator.validate(scenario)
        } catch {
            throw ScenarioStoreError.invalidScenario
        }

        let readable = try readableSnapshotForMutation()
        guard readable.scenario(id: scenario.id) == nil else {
            throw ScenarioStoreError.duplicateID
        }
        return try persistAndReload(readable.scenarios + [scenario])
    }

    func rename(
        id: String,
        name: String,
        at date: Date
    ) async throws -> ReadableScenarioSnapshot {
        let readable = try readableSnapshotForMutation()
        guard let index = readable.scenarios.firstIndex(where: { $0.id == id }) else {
            throw ScenarioStoreError.notFound
        }

        let renamed: ScenarioV1
        do {
            renamed = try readable.scenarios[index].renaming(to: name, at: date)
        } catch {
            throw ScenarioStoreError.invalidScenario
        }

        var scenarios = readable.scenarios
        scenarios[index] = renamed
        return try persistAndReload(scenarios)
    }

    func duplicate(
        id: String,
        newID: String,
        at date: Date
    ) async throws -> ReadableScenarioSnapshot {
        let readable = try readableSnapshotForMutation()
        guard readable.scenario(id: newID) == nil else {
            throw ScenarioStoreError.duplicateID
        }
        guard let source = readable.scenario(id: id) else {
            throw ScenarioStoreError.notFound
        }

        let name: String
        let duplicate: ScenarioV1
        do {
            name = try ScenarioDuplicateNamer.availableName(
                for: source.name,
                existingNames: Set(readable.scenarios.map(\.name))
            )
            duplicate = try source.duplicating(id: newID, name: name, at: date)
        } catch {
            throw ScenarioStoreError.invalidScenario
        }
        return try persistAndReload(readable.scenarios + [duplicate])
    }

    func delete(id: String) async throws -> ReadableScenarioSnapshot {
        let readable = try readableSnapshotForMutation()
        guard readable.scenario(id: id) != nil else {
            throw ScenarioStoreError.notFound
        }
        return try persistAndReload(readable.scenarios.filter { $0.id != id })
    }

    func resetAfterRecovery() async throws -> ReadableScenarioSnapshot {
        let preservedSource: Data
        do {
            _ = try readSnapshot()
            throw ScenarioStoreError.recoveryResetNotRequired
        } catch let failure as DocumentReadFailure {
            switch failure {
            case .corrupt, .unsupported:
                guard let source = preserveCurrentRecoverySource(),
                      currentDocumentMatches(source) else {
                    throw ScenarioStoreError.recoveryPreservationFailed
                }
                preservedSource = source
            case .unavailable:
                throw ScenarioStoreError.unavailable
            }
        }

        try write(
            scenarios: [],
            replacingRecoverySource: preservedSource
        )
        return try verifiedReload()
    }

    private func readableSnapshotForMutation() throws -> ReadableScenarioSnapshot {
        do {
            return try readSnapshot()
        } catch let failure as DocumentReadFailure {
            switch failure {
            case .unavailable:
                throw ScenarioStoreError.unavailable
            case .corrupt:
                throw ScenarioStoreError.corrupt
            case .unsupported:
                throw ScenarioStoreError.unsupported
            }
        } catch let error as ScenarioStoreError {
            throw error
        } catch {
            throw ScenarioStoreError.unavailable
        }
    }

    private func persistAndReload(_ scenarios: [ScenarioV1]) throws -> ReadableScenarioSnapshot {
        try write(scenarios: scenarios)
        return try verifiedReload()
    }

    private func verifiedReload() throws -> ReadableScenarioSnapshot {
        guard !failures.reloadAfterMutationFailure else {
            throw ScenarioStoreError.reloadFailed
        }
        do {
            return try readSnapshot(ignoreInjectedReadFailure: true)
        } catch {
            throw ScenarioStoreError.reloadFailed
        }
    }

    private func readSnapshot(
        ignoreInjectedReadFailure: Bool = false
    ) throws -> ReadableScenarioSnapshot {
        if failures.unavailableOnRead, !ignoreInjectedReadFailure {
            throw DocumentReadFailure.unavailable
        }
        if failures.corruptOnRead, !ignoreInjectedReadFailure {
            throw DocumentReadFailure.corrupt
        }
        if failures.unsupportedOnRead, !ignoreInjectedReadFailure {
            throw DocumentReadFailure.unsupported(
                UnsupportedScenarioStore(storeVersion: 2, scenarioVersion: nil)
            )
        }

        let directory: URL
        do {
            directory = try preparedDirectory()
        } catch {
            throw DocumentReadFailure.unavailable
        }
        let documentURL = directory.appendingPathComponent(
            ScenarioStoreConfiguration.documentFilename,
            isDirectory: false
        )
        guard fileManager.fileExists(atPath: documentURL.path) else {
            return ReadableScenarioSnapshot(scenarios: [])
        }

        let data: Data
        do {
            data = try Data(contentsOf: documentURL)
        } catch {
            throw DocumentReadFailure.unavailable
        }

        let storeProbe: StoreEnvelopeVersionProbe
        do {
            storeProbe = try JSONDecoder().decode(
                StoreEnvelopeVersionProbe.self,
                from: data
            )
        } catch {
            throw DocumentReadFailure.corrupt
        }
        guard storeProbe.storeVersion == ScenarioStoreConfiguration.envelopeVersion else {
            throw DocumentReadFailure.unsupported(
                UnsupportedScenarioStore(
                    storeVersion: storeProbe.storeVersion,
                    scenarioVersion: nil
                )
            )
        }

        let scenarioProbe: ScenarioListVersionProbe
        do {
            scenarioProbe = try JSONDecoder().decode(
                ScenarioListVersionProbe.self,
                from: data
            )
        } catch {
            throw DocumentReadFailure.corrupt
        }
        if let unsupportedScenario = scenarioProbe.scenarios.first(where: {
            $0.schemaVersion != ScenarioV1.currentSchemaVersion
        }) {
            throw DocumentReadFailure.unsupported(
                UnsupportedScenarioStore(
                    storeVersion: storeProbe.storeVersion,
                    scenarioVersion: unsupportedScenario.schemaVersion
                )
            )
        }

        let envelope: ScenarioStoreEnvelope
        do {
            envelope = try ScenarioJSONCodec.decoder().decode(
                ScenarioStoreEnvelope.self,
                from: data
            )
        } catch {
            throw DocumentReadFailure.corrupt
        }
        guard Set(envelope.scenarios.map(\.id)).count == envelope.scenarios.count else {
            throw DocumentReadFailure.corrupt
        }
        return ReadableScenarioSnapshot(scenarios: envelope.scenarios)
    }

    private func write(
        scenarios: [ScenarioV1],
        replacingRecoverySource expectedRecoverySource: Data? = nil
    ) throws {
        let envelope = ScenarioStoreEnvelope(
            storeVersion: ScenarioStoreConfiguration.envelopeVersion,
            scenarios: ScenarioOrdering.sorted(scenarios)
        )
        let data: Data
        do {
            data = try ScenarioJSONCodec.encoder().encode(envelope)
        } catch {
            throw ScenarioStoreError.invalidScenario
        }

        let directory: URL
        do {
            directory = try preparedDirectory()
        } catch {
            throw ScenarioStoreError.unavailable
        }
        let documentURL = directory.appendingPathComponent(
            ScenarioStoreConfiguration.documentFilename,
            isDirectory: false
        )
        let temporaryURL = directory.appendingPathComponent(
            ".scenarios-\(UUID().uuidString).tmp",
            isDirectory: false
        )

        guard !failures.temporaryWriteFailure else {
            throw ScenarioStoreError.temporaryWriteFailed
        }

        do {
            guard fileManager.createFile(
                atPath: temporaryURL.path,
                contents: nil,
                attributes: [.protectionKey: ScenarioStoreConfiguration.dataProtectionClass]
            ) else {
                throw ScenarioStoreError.temporaryWriteFailed
            }
            let handle = try FileHandle(forWritingTo: temporaryURL)
            do {
                try handle.write(contentsOf: data)
                try handle.synchronize()
                try handle.close()
            } catch {
                try? handle.close()
                throw error
            }
        } catch let error as ScenarioStoreError {
            try? fileManager.removeItem(at: temporaryURL)
            throw error
        } catch {
            try? fileManager.removeItem(at: temporaryURL)
            throw ScenarioStoreError.temporaryWriteFailed
        }

        do {
            if let expectedRecoverySource,
               !currentDocumentMatches(expectedRecoverySource) {
                throw ScenarioStoreError.recoveryPreservationFailed
            }
            if fileManager.fileExists(atPath: documentURL.path) {
                guard !failures.replacementFailure else {
                    throw ScenarioStoreError.replacementFailed
                }
                _ = try fileManager.replaceItemAt(
                    documentURL,
                    withItemAt: temporaryURL,
                    backupItemName: nil,
                    options: [.usingNewMetadataOnly]
                )
            } else {
                try fileManager.moveItem(at: temporaryURL, to: documentURL)
            }
        } catch let error as ScenarioStoreError {
            try? fileManager.removeItem(at: temporaryURL)
            throw error
        } catch {
            try? fileManager.removeItem(at: temporaryURL)
            throw ScenarioStoreError.replacementFailed
        }
    }

    private func preparedDirectory() throws -> URL {
        let directory: URL
        if let configuredURL = configuration.directoryURL {
            directory = configuredURL
        } else {
            var resolved = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            for component in configuration.applicationSupportDirectoryComponents {
                resolved.appendPathComponent(component, isDirectory: true)
            }
            directory = resolved
        }

        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.protectionKey: ScenarioStoreConfiguration.dataProtectionClass]
        )
        return directory
    }

    private func preserveRecoveryEvidence() -> ScenarioRecoveryEvidence {
        ScenarioRecoveryEvidence(
            sourcePreserved: preserveCurrentRecoverySource() != nil
        )
    }

    private func preserveCurrentRecoverySource() -> Data? {
        do {
            let directory = try preparedDirectory()
            let documentURL = directory.appendingPathComponent(
                ScenarioStoreConfiguration.documentFilename,
                isDirectory: false
            )
            guard fileManager.fileExists(atPath: documentURL.path) else {
                return nil
            }
            let sourceData = try Data(contentsOf: documentURL)
            let recoveryDirectory = directory.appendingPathComponent(
                "Recovery",
                isDirectory: true
            )

            if recoveryCopyExists(
                matching: sourceData,
                in: recoveryDirectory
            ) {
                return currentDocumentMatches(sourceData) ? sourceData : nil
            }

            guard !failures.recoveryCopyFailure else {
                return nil
            }
            if let copyLimit = failures.recoveryCopyFailureAfterSuccessfulCopies,
               successfulRecoveryCopyCount >= copyLimit {
                return nil
            }

            try fileManager.createDirectory(
                at: recoveryDirectory,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: ScenarioStoreConfiguration.dataProtectionClass]
            )
            let destination = recoveryDirectory.appendingPathComponent(
                "scenarios-recovery-\(UUID().uuidString).json",
                isDirectory: false
            )
            try writeRecoveryCopy(sourceData, to: destination)
            guard try Data(contentsOf: destination) == sourceData else {
                return nil
            }
            successfulRecoveryCopyCount += 1
            return currentDocumentMatches(sourceData) ? sourceData : nil
        } catch {
            return nil
        }
    }

    private func recoveryCopyExists(
        matching sourceData: Data,
        in recoveryDirectory: URL
    ) -> Bool {
        guard let recoveryURLs = try? fileManager.contentsOfDirectory(
            at: recoveryDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return false
        }
        return recoveryURLs.contains { recoveryURL in
            guard let recoveryData = try? Data(contentsOf: recoveryURL) else {
                return false
            }
            return recoveryData == sourceData
        }
    }

    private func currentDocumentMatches(_ sourceData: Data) -> Bool {
        do {
            let directory = try preparedDirectory()
            let documentURL = directory.appendingPathComponent(
                ScenarioStoreConfiguration.documentFilename,
                isDirectory: false
            )
            return try Data(contentsOf: documentURL) == sourceData
        } catch {
            return false
        }
    }

    private func writeRecoveryCopy(_ data: Data, to destination: URL) throws {
        guard fileManager.createFile(
            atPath: destination.path,
            contents: nil,
            attributes: [.protectionKey: ScenarioStoreConfiguration.dataProtectionClass]
        ) else {
            throw ScenarioStoreError.recoveryPreservationFailed
        }

        do {
            let handle = try FileHandle(forWritingTo: destination)
            do {
                try handle.write(contentsOf: data)
                try handle.synchronize()
                try handle.close()
            } catch {
                try? handle.close()
                throw error
            }
        } catch {
            try? fileManager.removeItem(at: destination)
            throw error
        }
    }
}

private enum DocumentReadFailure: Error {
    case unavailable
    case corrupt
    case unsupported(UnsupportedScenarioStore)
}

private struct StoreEnvelopeVersionProbe: Decodable {
    let storeVersion: Int
}

private struct ScenarioListVersionProbe: Decodable {
    let scenarios: [ScenarioVersionProbe]
}

private struct ScenarioVersionProbe: Decodable {
    let schemaVersion: Int
}

private struct ScenarioStoreEnvelope: Codable {
    let storeVersion: Int
    let scenarios: [ScenarioV1]

    enum CodingKeys: String, CodingKey, CaseIterable {
        case storeVersion
        case scenarios
    }

    init(storeVersion: Int, scenarios: [ScenarioV1]) {
        self.storeVersion = storeVersion
        self.scenarios = scenarios
    }

    init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(allowing: CodingKeys.allCases.map(\.rawValue))
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storeVersion = try container.decode(Int.self, forKey: .storeVersion)
        scenarios = try container.decode([ScenarioV1].self, forKey: .scenarios)
    }
}
