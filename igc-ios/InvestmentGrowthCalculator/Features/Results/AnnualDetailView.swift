import SwiftUI

private enum AnnualDetailMode: String, CaseIterable, Identifiable {
    case afterFees = "After fees"
    case beforeFees = "Before fees"
    case afterFeesToday = "After fees in today’s money"
    case beforeFeesToday = "Before fees in today’s money"

    var id: Self { self }

    var explanation: String {
        switch self {
        case .afterFees: "Future-pound balances after the modelled annual fee."
        case .beforeFees: "Future-pound balances on the no-fee path."
        case .afterFeesToday: "After-fee balances adjusted by the inflation assumption."
        case .beforeFeesToday: "No-fee balances adjusted by the inflation assumption."
        }
    }
}

struct AnnualDetailView: View {
    let snapshot: ProjectionSnapshot

    @State private var mode: AnnualDetailMode = .afterFees
    @State private var expandedYears: Set<Int> = []

    var body: some View {
        List {
            Section {
                Picker("Annual view", selection: $mode) {
                    ForEach(AnnualDetailMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("annual.mode")
                Text(mode.explanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Annual rows") {
                ForEach(snapshot.result.annualRows) { row in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedYears.contains(row.year) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedYears.insert(row.year)
                                } else {
                                    expandedYears.remove(row.year)
                                }
                            }
                        )
                    ) {
                        annualFacts(row)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(row.isPartial ? "Year \(row.year) (partial)" : "Year \(row.year)")
                                .font(.headline)
                            Text(IGCFormatters.gbp(closingBalance(row)))
                                .monospacedDigit()
                        }
                    }
                    .accessibilityIdentifier("annual.row.\(row.year)")
                }
            }

            Section("Final context") {
                LabeledContent(
                    mode.rawValue,
                    value: IGCFormatters.gbp(finalBalance)
                )
                LabeledContent(
                    "Duration",
                    value: IGCFormatters.duration(
                        years: snapshot.input.years,
                        months: snapshot.input.months
                    )
                )
            }
        }
        .navigationTitle("Annual detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func annualFacts(_ row: AnnualCalculationRow) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            fact("Opening balance", openingBalance(row))
            fact("Contributions", contributions(row))
            fact("Growth", growth(row))
            if mode == .afterFees || mode == .afterFeesToday {
                fact("Fees paid in this year", fees(row))
            }
            fact("Closing balance", closingBalance(row))
        }
        .padding(.vertical, 8)
    }

    private func fact(_ label: String, _ value: Double) -> some View {
        LabeledContent(label, value: IGCFormatters.gbp(value))
    }

    private func discount(at period: Int) -> Double {
        pow(1 + snapshot.input.inflationRate, Double(period) / 12)
    }

    private func openingBalance(_ row: AnnualCalculationRow) -> Double {
        let nominal = switch mode {
        case .afterFees, .afterFeesToday: row.startingBalanceAfterFees
        case .beforeFees, .beforeFeesToday: row.startingBalance
        }
        switch mode {
        case .afterFeesToday, .beforeFeesToday:
            return nominal / discount(at: row.endPeriod - row.periodCount)
        case .afterFees, .beforeFees:
            return nominal
        }
    }

    private func contributions(_ row: AnnualCalculationRow) -> Double {
        switch mode {
        case .afterFeesToday, .beforeFeesToday:
            row.contributions / discount(at: row.endPeriod)
        case .afterFees, .beforeFees:
            row.contributions
        }
    }

    private func growth(_ row: AnnualCalculationRow) -> Double {
        switch mode {
        case .beforeFees: row.interest
        case .beforeFeesToday: row.interest / discount(at: row.endPeriod)
        case .afterFees:
            row.endingBalanceAfterFees - row.startingBalanceAfterFees - row.contributions
        case .afterFeesToday:
            closingBalance(row) - openingBalance(row) - contributions(row)
        }
    }

    private func fees(_ row: AnnualCalculationRow) -> Double {
        mode == .afterFeesToday
            ? row.yearlyFeesPaid / discount(at: row.endPeriod)
            : row.yearlyFeesPaid
    }

    private func closingBalance(_ row: AnnualCalculationRow) -> Double {
        switch mode {
        case .afterFees: row.endingBalanceAfterFees
        case .beforeFees: row.endingBalance
        case .afterFeesToday: row.realEndingBalanceAfterFees
        case .beforeFeesToday: row.realEndingBalance
        }
    }

    private var finalBalance: Double {
        switch mode {
        case .afterFees: snapshot.result.finalBalanceAfterFees
        case .beforeFees: snapshot.result.finalBalance
        case .afterFeesToday: snapshot.result.finalBalanceAfterFeesReal
        case .beforeFeesToday: snapshot.result.finalBalanceReal
        }
    }
}
