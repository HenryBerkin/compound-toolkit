import Foundation

enum CalculationError: Error, Equatable {
    case invalidInput([ValidationField])
    case nonFiniteResult
}

enum CalculationEngine {
    static func effectiveMonthlyRate(
        annualRate: Double,
        compoundFrequency: CompoundFrequency
    ) -> Double {
        if annualRate == 0 { return 0 }
        switch compoundFrequency {
        case .daily:
            return pow(1 + annualRate / 365, 365 / 12) - 1
        case .monthly:
            return annualRate / 12
        case .quarterly:
            return pow(1 + annualRate / 4, 1 / 3) - 1
        case .annual:
            return pow(1 + annualRate, 1 / 12) - 1
        }
    }

    static func effectiveMonthlyFeeRate(
        annualFeeRate: Double,
        compoundFrequency: CompoundFrequency
    ) -> Double {
        if annualFeeRate == 0 { return 0 }
        switch compoundFrequency {
        case .daily:
            return 1 - pow(1 - annualFeeRate / 365, 365 / 12)
        case .monthly:
            return annualFeeRate / 12
        case .quarterly:
            return 1 - pow(1 - annualFeeRate / 4, 1 / 3)
        case .annual:
            return 1 - pow(1 - annualFeeRate, 1 / 12)
        }
    }

    static func effectiveMonthlyContribution(
        contribution: Double,
        frequency: ContributionFrequency
    ) -> Double {
        switch frequency {
        case .weekly: contribution * 52 / 12
        case .monthly: contribution
        case .annual: contribution / 12
        }
    }

    static func calculate(_ input: CalculationInput) throws -> CalculationResult {
        let validation = CalculationValidator.validate(input.candidate)
        guard validation.isValid else {
            throw CalculationError.invalidInput(validation.errorFields)
        }

        let monthlyRate = effectiveMonthlyRate(
            annualRate: input.apr,
            compoundFrequency: input.compoundFrequency
        )
        let monthlyFeeRate = effectiveMonthlyFeeRate(
            annualFeeRate: input.annualFeeRate,
            compoundFrequency: input.compoundFrequency
        )
        let monthlyContribution = effectiveMonthlyContribution(
            contribution: input.contribution,
            frequency: input.contributionFrequency
        )

        var balance = input.principal
        var balanceAfterFees = input.principal
        var cumulativeContributions = 0.0
        var cumulativeInterest = 0.0
        var cumulativeFees = 0.0
        var monthlyRows: [MonthlyCalculationRow] = []
        monthlyRows.reserveCapacity(input.totalMonths)

        for period in 1...input.totalMonths {
            let startingBalance = balance
            let startingBalanceAfterFees = balanceAfterFees
            let periodInterest: Double
            let periodFee: Double

            switch input.timing {
            case .start:
                balance += monthlyContribution
                periodInterest = balance * monthlyRate
                balance += periodInterest

                balanceAfterFees += monthlyContribution
                let postGrowth = balanceAfterFees * (1 + monthlyRate)
                periodFee = postGrowth * monthlyFeeRate
                balanceAfterFees = postGrowth - periodFee
            case .end:
                periodInterest = balance * monthlyRate
                balance += periodInterest
                balance += monthlyContribution

                let postGrowth = balanceAfterFees * (1 + monthlyRate)
                periodFee = postGrowth * monthlyFeeRate
                balanceAfterFees = postGrowth - periodFee
                balanceAfterFees += monthlyContribution
            }

            cumulativeContributions += monthlyContribution
            cumulativeInterest += periodInterest
            cumulativeFees += periodFee

            monthlyRows.append(
                MonthlyCalculationRow(
                    period: period,
                    year: (period + 11) / 12,
                    month: ((period - 1) % 12) + 1,
                    startingBalance: startingBalance,
                    contributions: monthlyContribution,
                    interest: periodInterest,
                    endingBalance: balance,
                    cumulativeContributions: cumulativeContributions,
                    cumulativeInterest: cumulativeInterest,
                    startingBalanceAfterFees: startingBalanceAfterFees,
                    feePaid: periodFee,
                    cumulativeFeesPaid: cumulativeFees,
                    endingBalanceAfterFees: balanceAfterFees
                )
            )
        }

        let annualRows = aggregateAnnualRows(
            monthlyRows,
            inflationRate: input.inflationRate
        )
        let finalDiscount = inflationDiscountFactor(
            inflationRate: input.inflationRate,
            elapsedYears: Double(input.totalMonths) / 12
        )

        let result = CalculationResult(
            finalBalance: balance,
            totalContributions: cumulativeContributions,
            totalInterest: cumulativeInterest,
            totalFeesPaidNominal: cumulativeFees,
            finalBalanceAfterFees: balanceAfterFees,
            finalBalanceReal: balance / finalDiscount,
            totalContributionsReal: cumulativeContributions / finalDiscount,
            totalInterestReal: cumulativeInterest / finalDiscount,
            totalFeesPaidReal: cumulativeFees / finalDiscount,
            finalBalanceAfterFeesReal: balanceAfterFees / finalDiscount,
            effectiveMonthlyRate: monthlyRate,
            effectiveMonthlyFeeRate: monthlyFeeRate,
            effectiveMonthlyContribution: monthlyContribution,
            monthlyRows: monthlyRows,
            annualRows: annualRows
        )

        guard result.allScalarValuesAreFinite,
              result.monthlyRows.allSatisfy(\.allValuesAreFinite),
              result.annualRows.allSatisfy(\.allValuesAreFinite) else {
            throw CalculationError.nonFiniteResult
        }
        return result
    }

    private static func inflationDiscountFactor(
        inflationRate: Double,
        elapsedYears: Double
    ) -> Double {
        inflationRate == 0 ? 1 : pow(1 + inflationRate, elapsedYears)
    }

    private static func aggregateAnnualRows(
        _ monthlyRows: [MonthlyCalculationRow],
        inflationRate: Double
    ) -> [AnnualCalculationRow] {
        Dictionary(grouping: monthlyRows, by: \.year)
            .keys
            .sorted()
            .compactMap { year in
                guard let rows = Dictionary(grouping: monthlyRows, by: \.year)[year],
                      let first = rows.first,
                      let last = rows.last else { return nil }
                let discount = inflationDiscountFactor(
                    inflationRate: inflationRate,
                    elapsedYears: Double(last.period) / 12
                )
                return AnnualCalculationRow(
                    year: year,
                    periodCount: rows.count,
                    endPeriod: last.period,
                    startingBalance: first.startingBalance,
                    startingBalanceAfterFees: first.startingBalanceAfterFees,
                    contributions: rows.reduce(0) { $0 + $1.contributions },
                    interest: rows.reduce(0) { $0 + $1.interest },
                    endingBalance: last.endingBalance,
                    cumulativeContributions: last.cumulativeContributions,
                    cumulativeInterest: last.cumulativeInterest,
                    yearlyFeesPaid: rows.reduce(0) { $0 + $1.feePaid },
                    cumulativeFeesPaid: last.cumulativeFeesPaid,
                    endingBalanceAfterFees: last.endingBalanceAfterFees,
                    realEndingBalance: last.endingBalance / discount,
                    realEndingBalanceAfterFees: last.endingBalanceAfterFees / discount,
                    realCumulativeContributions: last.cumulativeContributions / discount,
                    realCumulativeInterest: last.cumulativeInterest / discount
                )
            }
    }
}

private extension CalculationResult {
    var allScalarValuesAreFinite: Bool {
        [
            finalBalance,
            totalContributions,
            totalInterest,
            totalFeesPaidNominal,
            finalBalanceAfterFees,
            finalBalanceReal,
            totalContributionsReal,
            totalInterestReal,
            totalFeesPaidReal,
            finalBalanceAfterFeesReal,
            effectiveMonthlyRate,
            effectiveMonthlyFeeRate,
            effectiveMonthlyContribution,
        ].allSatisfy(\.isFinite)
    }
}

private extension MonthlyCalculationRow {
    var allValuesAreFinite: Bool {
        [
            startingBalance,
            contributions,
            interest,
            endingBalance,
            cumulativeContributions,
            cumulativeInterest,
            startingBalanceAfterFees,
            feePaid,
            cumulativeFeesPaid,
            endingBalanceAfterFees,
        ].allSatisfy(\.isFinite)
    }
}

private extension AnnualCalculationRow {
    var allValuesAreFinite: Bool {
        [
            startingBalance,
            startingBalanceAfterFees,
            contributions,
            interest,
            endingBalance,
            cumulativeContributions,
            cumulativeInterest,
            yearlyFeesPaid,
            cumulativeFeesPaid,
            endingBalanceAfterFees,
            realEndingBalance,
            realEndingBalanceAfterFees,
            realCumulativeContributions,
            realCumulativeInterest,
        ].allSatisfy(\.isFinite)
    }
}
