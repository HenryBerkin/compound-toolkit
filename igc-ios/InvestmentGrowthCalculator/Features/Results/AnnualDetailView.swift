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
        case .afterFeesToday:
            "After-fee balances expressed in the purchasing power at the end of each year."
        case .beforeFeesToday:
            "No-fee balances expressed in the purchasing power at the end of each year."
        }
    }

    var isAfterFees: Bool {
        self == .afterFees || self == .afterFeesToday
    }

    var isTodayMoney: Bool {
        self == .afterFeesToday || self == .beforeFeesToday
    }

    /// Growth on the after-fee path is measured net of the fee already deducted, so the
    /// fee line is context rather than a further subtraction.
    var rowNote: String {
        var note = isAfterFees
            ? "Growth after fees is already net of the fee shown, so opening balance, "
                + "contributions and growth add up to the closing balance."
            : "Opening balance, contributions and growth add up to the closing balance."
        if isTodayMoney {
            note += " Every amount in a year uses that year’s end as its today’s-money "
                + "basis, so an opening balance is not the previous year’s closing balance."
        }
        return note
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
                FinancialFactRow(
                    label: mode.rawValue,
                    value: IGCFormatters.gbp(finalBalance),
                    isEmphasised: true
                )
                FinancialFactRow(
                    label: "Duration",
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
            fact(mode.isAfterFees ? "Growth after fees" : "Growth", growth(row))
            if mode.isAfterFees {
                fact("Fees deducted this year", fees(row))
            }
            fact("Closing balance", closingBalance(row))
            Text(mode.rowNote)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
    }

    private func fact(_ label: String, _ value: Double) -> some View {
        FinancialFactRow(label: label, value: IGCFormatters.gbp(value))
    }

    private func discount(at period: Int) -> Double {
        pow(1 + snapshot.input.inflationRate, Double(period) / 12)
    }

    /// Every amount in a row is discounted at the same row-end divisor the shared
    /// contract uses for that row's closing balance. Mixing divisors within one row
    /// breaks the additive reading the layout invites.
    private func inTodayMoneyIfNeeded(_ nominal: Double, _ row: AnnualCalculationRow) -> Double {
        mode.isTodayMoney ? nominal / discount(at: row.endPeriod) : nominal
    }

    private func openingBalance(_ row: AnnualCalculationRow) -> Double {
        let nominal = mode.isAfterFees ? row.startingBalanceAfterFees : row.startingBalance
        return inTodayMoneyIfNeeded(nominal, row)
    }

    private func contributions(_ row: AnnualCalculationRow) -> Double {
        inTodayMoneyIfNeeded(row.contributions, row)
    }

    private func growth(_ row: AnnualCalculationRow) -> Double {
        let nominal = mode.isAfterFees
            ? row.endingBalanceAfterFees - row.startingBalanceAfterFees - row.contributions
            : row.interest
        return inTodayMoneyIfNeeded(nominal, row)
    }

    private func fees(_ row: AnnualCalculationRow) -> Double {
        inTodayMoneyIfNeeded(row.yearlyFeesPaid, row)
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
