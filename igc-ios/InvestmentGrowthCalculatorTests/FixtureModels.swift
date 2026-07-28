import Foundation
@testable import InvestmentGrowthCalculator

struct CalculationFixtureEnvelope: Decodable {
    let contractVersion: Int
    let currency: String
    let tolerances: FixtureTolerances
    let calculationCases: [FixtureCalculationCase]
    let validationCases: [FixtureValidationCase]
}

struct FixtureTolerances: Decodable {
    let absolute: Double
    let relative: Double
    let rateAbsolute: Double
}

struct FixtureCalculationCase: Decodable {
    let id: String
    let description: String
    let input: CalculationCandidate
    let expectedMonthlyRate: Double
    let expectedMonthlyContribution: Double
    let expected: FixtureExpectedResult
    let monthlyCheckpoints: [FixtureMonthlyCheckpoint]
    let yearlyCheckpoints: [FixtureAnnualCheckpoint]
}

struct FixtureExpectedResult: Decodable {
    let finalBalance: Double
    let totalContributions: Double
    let totalInterest: Double
    let totalFeesPaidNominal: Double
    let finalBalanceAfterFees: Double
    let finalBalanceReal: Double
    let totalContributionsReal: Double
    let totalInterestReal: Double
    let totalFeesPaidReal: Double
    let finalBalanceAfterFeesReal: Double
    let monthlyCount: Int
    let yearlyCount: Int
}

struct FixtureMonthlyCheckpoint: Decodable {
    let period: Int
    let year: Int
    let month: Int
    let startingBalance: Double
    let contributions: Double
    let interest: Double
    let endingBalance: Double
    let cumulativeContributions: Double
    let cumulativeInterest: Double
}

struct FixtureAnnualCheckpoint: Decodable {
    let year: Int
    let startingBalance: Double
    let contributions: Double
    let interest: Double
    let endingBalance: Double
    let cumulativeContributions: Double
    let cumulativeInterest: Double
    let yearlyFeesPaid: Double
    let cumulativeFeesPaid: Double
    let endingBalanceAfterFees: Double
    let realEndingBalance: Double
    let realCumulativeContributions: Double
    let realCumulativeInterest: Double
}

struct FixtureValidationCase: Decodable {
    let id: String
    let candidate: CalculationCandidate
    let valid: Bool
    let errorFields: [ValidationField]
}

enum FixtureLoaderError: Error, Equatable, LocalizedError {
    case missingResource(String)
    case malformed(String)
    case unsupportedContractVersion(Int)
    case unsupportedCurrency(String)

    var errorDescription: String? {
        switch self {
        case .missingResource(let name): "Missing fixture resource: \(name)"
        case .malformed(let detail): "Malformed calculation fixture: \(detail)"
        case .unsupportedContractVersion(let version): "Unsupported calculation contract version: \(version)"
        case .unsupportedCurrency(let currency): "Unsupported fixture currency: \(currency)"
        }
    }
}

enum CalculationFixtureLoader {
    static func load(
        resource name: String = "calculation-v1",
        bundle: Bundle
    ) throws -> (fixture: CalculationFixtureEnvelope, source: URL) {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw FixtureLoaderError.missingResource("\(name).json")
        }
        return (try decode(Data(contentsOf: url)), url)
    }

    static func decode(_ data: Data) throws -> CalculationFixtureEnvelope {
        let fixture: CalculationFixtureEnvelope
        do {
            fixture = try JSONDecoder().decode(CalculationFixtureEnvelope.self, from: data)
        } catch {
            throw FixtureLoaderError.malformed(error.localizedDescription)
        }
        guard fixture.contractVersion == 1 else {
            throw FixtureLoaderError.unsupportedContractVersion(fixture.contractVersion)
        }
        guard fixture.currency == Currency.GBP.rawValue else {
            throw FixtureLoaderError.unsupportedCurrency(fixture.currency)
        }
        guard !fixture.calculationCases.isEmpty, !fixture.validationCases.isEmpty else {
            throw FixtureLoaderError.malformed("Expected calculation and validation cases.")
        }
        return fixture
    }
}
