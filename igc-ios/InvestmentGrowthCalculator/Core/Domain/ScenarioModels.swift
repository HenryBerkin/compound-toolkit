import Foundation

enum ScenarioNameError: Error, Equatable, LocalizedError, Sendable {
    case empty
    case tooLong

    var errorDescription: String? {
        switch self {
        case .empty:
            "Enter a scenario name."
        case .tooLong:
            "Use no more than 120 characters."
        }
    }
}

enum ScenarioModelError: Error, Equatable, LocalizedError, Sendable {
    case unsupportedSchemaVersion(Int)
    case invalidID
    case invalidName(ScenarioNameError)
    case invalidCurrency
    case invalidInputs([ValidationField])
    case invalidTarget
    case invalidTimestamp

    var errorDescription: String? {
        switch self {
        case let .unsupportedSchemaVersion(version):
            "Unsupported scenario version \(version)."
        case .invalidID:
            "The scenario identifier is invalid."
        case let .invalidName(error):
            error.localizedDescription
        case .invalidCurrency:
            "The scenario currency is unsupported."
        case .invalidInputs:
            "The scenario assumptions are invalid."
        case .invalidTarget:
            "The scenario target is invalid."
        case .invalidTimestamp:
            "The scenario timestamp is invalid."
        }
    }
}

enum ScenarioNameValidator {
    static let maximumPortableLength = 120

    static func normalized(_ proposedName: String) throws -> String {
        let trimmed = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ScenarioNameError.empty
        }
        guard portableLength(of: trimmed) <= maximumPortableLength else {
            throw ScenarioNameError.tooLong
        }
        return trimmed
    }

    static func validateStored(_ name: String) throws {
        let normalized = try normalized(name)
        guard normalized == name else {
            throw ScenarioNameError.empty
        }
    }

    static func portableLength(of value: String) -> Int {
        value.unicodeScalars.count
    }
}

struct ScenarioV1: Codable, Equatable, Identifiable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let id: String
    let name: String
    let currency: Currency
    let inputs: CalculationInput
    let presetID: PresetID?
    let targetToday: Double?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion
        case id
        case name
        case currency
        case inputs
        case presetID = "presetId"
        case targetToday
        case createdAt
        case updatedAt
    }

    init(
        id: String,
        name: String,
        inputs: CalculationInput,
        presetID: PresetID?,
        targetToday: Double?,
        createdAt: Date,
        updatedAt: Date
    ) throws {
        self.schemaVersion = Self.currentSchemaVersion
        self.id = id
        self.name = try ScenarioNameValidator.normalized(name)
        self.currency = .GBP
        self.inputs = inputs
        self.presetID = presetID
        self.targetToday = targetToday
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        try ScenarioValidator.validate(self)
    }

    init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(allowing: CodingKeys.allCases.map(\.rawValue))
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        currency = try container.decode(Currency.self, forKey: .currency)
        inputs = try container.decode(ScenarioInputsV1.self, forKey: .inputs).calculationInput
        presetID = try container.decodeIfPresent(PresetID.self, forKey: .presetID)
        targetToday = try container.decodeIfPresent(Double.self, forKey: .targetToday)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)

        do {
            try ScenarioValidator.validate(self)
        } catch {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: error.localizedDescription,
                    underlyingError: error
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        try ScenarioValidator.validate(self)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(currency, forKey: .currency)
        try container.encode(ScenarioInputsV1(inputs), forKey: .inputs)
        try container.encode(presetID, forKey: .presetID)
        try container.encodeIfPresent(targetToday, forKey: .targetToday)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    func renaming(to proposedName: String, at date: Date) throws -> ScenarioV1 {
        try ScenarioV1(
            id: id,
            name: proposedName,
            inputs: inputs,
            presetID: presetID,
            targetToday: targetToday,
            createdAt: createdAt,
            updatedAt: date
        )
    }

    func duplicating(id newID: String, name newName: String, at date: Date) throws -> ScenarioV1 {
        try ScenarioV1(
            id: newID,
            name: newName,
            inputs: inputs,
            presetID: presetID,
            targetToday: targetToday,
            createdAt: date,
            updatedAt: date
        )
    }
}

enum ScenarioValidator {
    static func validate(_ scenario: ScenarioV1) throws {
        guard scenario.schemaVersion == ScenarioV1.currentSchemaVersion else {
            throw ScenarioModelError.unsupportedSchemaVersion(scenario.schemaVersion)
        }
        guard !scenario.id.isEmpty,
              scenario.id.unicodeScalars.count <= 128 else {
            throw ScenarioModelError.invalidID
        }
        do {
            try ScenarioNameValidator.validateStored(scenario.name)
        } catch let error as ScenarioNameError {
            throw ScenarioModelError.invalidName(error)
        }
        guard scenario.currency == .GBP else {
            throw ScenarioModelError.invalidCurrency
        }

        let validation = CalculationValidator.validate(scenario.inputs.candidate)
        guard validation.isValid else {
            throw ScenarioModelError.invalidInputs(validation.errorFields)
        }
        if let target = scenario.targetToday,
           !target.isFinite || target < 0 {
            throw ScenarioModelError.invalidTarget
        }
        guard scenario.createdAt.timeIntervalSinceReferenceDate.isFinite,
              scenario.updatedAt.timeIntervalSinceReferenceDate.isFinite else {
            throw ScenarioModelError.invalidTimestamp
        }
    }
}

enum ScenarioOrdering {
    static func sorted(_ scenarios: [ScenarioV1]) -> [ScenarioV1] {
        scenarios.sorted { lhs, rhs in
            if lhs.updatedAt != rhs.updatedAt {
                return lhs.updatedAt > rhs.updatedAt
            }
            if lhs.createdAt != rhs.createdAt {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.id < rhs.id
        }
    }
}

enum ScenarioDuplicateNamer {
    static func availableName(for original: String, existingNames: Set<String>) throws -> String {
        var copyNumber = 1
        while copyNumber < Int.max {
            let suffix = copyNumber == 1 ? " copy" : " copy \(copyNumber)"
            var base = original

            while !base.isEmpty,
                  ScenarioNameValidator.portableLength(of: base + suffix)
                    > ScenarioNameValidator.maximumPortableLength {
                base.removeLast()
            }

            let candidate = base.isEmpty
                ? String(suffix.dropFirst())
                : base + suffix
            let validated = try ScenarioNameValidator.normalized(candidate)
            if !existingNames.contains(validated) {
                return validated
            }
            copyNumber += 1
        }
        throw ScenarioNameError.tooLong
    }
}

private struct ScenarioInputsV1: Codable {
    let principal: Double
    let contribution: Double
    let contributionFrequency: ContributionFrequency
    let apr: Double
    let inflationRate: Double
    let annualFeeRate: Double
    let compoundFrequency: CompoundFrequency
    let years: Int
    let months: Int
    let timing: ContributionTiming

    enum CodingKeys: String, CodingKey, CaseIterable {
        case principal
        case contribution
        case contributionFrequency
        case apr
        case inflationRate
        case annualFeeRate
        case compoundFrequency
        case years
        case months
        case timing
    }

    init(_ input: CalculationInput) {
        principal = input.principal
        contribution = input.contribution
        contributionFrequency = input.contributionFrequency
        apr = input.apr
        inflationRate = input.inflationRate
        annualFeeRate = input.annualFeeRate
        compoundFrequency = input.compoundFrequency
        years = input.years
        months = input.months
        timing = input.timing
    }

    init(from decoder: Decoder) throws {
        try decoder.rejectUnknownKeys(allowing: CodingKeys.allCases.map(\.rawValue))
        let container = try decoder.container(keyedBy: CodingKeys.self)
        principal = try container.decode(Double.self, forKey: .principal)
        contribution = try container.decode(Double.self, forKey: .contribution)
        contributionFrequency = try container.decode(
            ContributionFrequency.self,
            forKey: .contributionFrequency
        )
        apr = try container.decode(Double.self, forKey: .apr)
        inflationRate = try container.decode(Double.self, forKey: .inflationRate)
        annualFeeRate = try container.decode(Double.self, forKey: .annualFeeRate)
        compoundFrequency = try container.decode(
            CompoundFrequency.self,
            forKey: .compoundFrequency
        )
        years = try container.decode(Int.self, forKey: .years)
        months = try container.decode(Int.self, forKey: .months)
        timing = try container.decode(ContributionTiming.self, forKey: .timing)
    }

    var calculationInput: CalculationInput {
        CalculationInput(
            principal: principal,
            contribution: contribution,
            contributionFrequency: contributionFrequency,
            apr: apr,
            inflationRate: inflationRate,
            annualFeeRate: annualFeeRate,
            compoundFrequency: compoundFrequency,
            years: years,
            months: months,
            timing: timing
        )
    }
}

struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension Decoder {
    func rejectUnknownKeys(allowing allowedKeys: [String]) throws {
        let container = try self.container(keyedBy: AnyCodingKey.self)
        let unknown = Set(container.allKeys.map(\.stringValue))
            .subtracting(allowedKeys)
        guard unknown.isEmpty else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Unknown keys: \(unknown.sorted().joined(separator: ", "))."
                )
            )
        }
    }
}
