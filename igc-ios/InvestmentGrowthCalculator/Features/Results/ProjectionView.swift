import Charts
import SwiftUI

struct ProjectionView: View {
    let snapshot: ProjectionSnapshot
    @ObservedObject var scenarioLibrary: ScenarioLibraryModel
    let showAnnualDetail: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showAfterFees = true
    @State private var showTodayMoney = true
    @State private var showsSaveSheet = false
    @State private var savedStatus: String?

    private var chartPoints: [ProjectionChartPoint] {
        ProjectionPresenter.chartPoints(input: snapshot.input, result: snapshot.result)
            .filter { point in
                switch point.series {
                case .afterFees: showAfterFees
                case .todayMoney: showTodayMoney
                }
            }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Illustrative projection based on constant rates and contributions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let savedStatus {
                    ScenarioStatusBanner(kind: .success, message: savedStatus)
                        .accessibilityIdentifier("projection.savedStatus")
                }

                kpi
                todayMoneyContext

                if let analysis = snapshot.targetAnalysis {
                    targetStatus(analysis)
                }

                composition
                feeImpact
                growthChart
                assumptions

                Text("This projection is based on your assumptions. It is not financial advice or a forecast.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: 840, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Projection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(saveActionLabel) {
                    showsSaveSheet = true
                }
                .accessibilityIdentifier("projection.save")
            }
        }
        .sheet(isPresented: $showsSaveSheet) {
            ScenarioNameEntryView(
                title: "Save scenario",
                initialName: suggestedName,
                actionLabel: "Save",
                accessibilityPrefix: "projection.saveSheet",
                submit: { name in
                    try await scenarioLibrary.createNew(
                        from: snapshot,
                        proposedName: name
                    )
                },
                onSuccess: { name in
                    savedStatus = "Saved “\(name)”"
                }
            )
        }
    }

    private var saveActionLabel: String {
        snapshot.sourceScenarioID == nil ? "Save" : "Save as new"
    }

    private var suggestedName: String {
        if snapshot.input.months == 0 {
            return "\(snapshot.input.years)-year projection"
        }
        return "\(snapshot.input.totalMonths)-month projection"
    }

    private var kpi: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Final balance after fees")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(IGCFormatters.gbp(snapshot.result.finalBalanceAfterFees))
                .font(.largeTitle.bold())
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("projection.finalBalance")
            Text("After \(IGCFormatters.duration(years: snapshot.input.years, months: snapshot.input.months))")
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.separator)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var todayMoneyContext: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("In today’s money")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(IGCFormatters.gbp(snapshot.result.finalBalanceAfterFeesReal))
                .font(.title2.bold())
                .monospacedDigit()
                .accessibilityIdentifier("projection.todayMoney")
            Text("Using \(IGCFormatters.percent(snapshot.input.inflationRate)) inflation.")
                .foregroundStyle(.secondary)
        }
    }

    private func targetStatus(_ analysis: TargetAnalysis) -> some View {
        let presentation = targetPresentation(analysis.status)
        return VStack(alignment: .leading, spacing: 8) {
            Label(presentation.title, systemImage: presentation.symbol)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(IGCFormatters.targetGapText(analysis))
                .font(.body)
            LabeledContent(
                "Target in today’s money",
                value: IGCFormatters.gbp(analysis.targetToday)
            )
            LabeledContent(
                "Equivalent future amount",
                value: IGCFormatters.gbp(analysis.nominalTargetAtHorizon)
            )
        }
        .padding()
        .background(.secondary.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("projection.targetStatus")
    }

    private var composition: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Breakdown")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            financialFact("Starting balance", snapshot.input.principal)
            financialFact("Regular contributions added", snapshot.result.totalContributions)
            financialFact(
                "Growth after fees",
                snapshot.result.finalBalanceAfterFees
                    - snapshot.input.principal
                    - snapshot.result.totalContributions
            )
            financialFact("Balance before fees", snapshot.result.finalBalance)
        }
    }

    private var feeImpact: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fee impact")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            financialFact("Fees paid", snapshot.result.totalFeesPaidNominal)
            financialFact(
                "Difference caused by fees",
                snapshot.result.finalBalance - snapshot.result.finalBalanceAfterFees
            )
            Text("The difference can exceed fees paid because deducted fees do not receive later growth.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var growthChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Balance over time")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Text(ProjectionPresenter.factualSummary(input: snapshot.input, result: snapshot.result))
                .accessibilityIdentifier("projection.chartSummary")

            Toggle("After fees — solid line and circle marks", isOn: afterFeesBinding)
                .tint(.indigo)
                .frame(minHeight: 44)
                .accessibilityIdentifier("projection.toggleAfterFees")
            Toggle("After fees in today’s money — dashed line and diamond marks", isOn: todayMoneyBinding)
                .tint(.teal)
                .frame(minHeight: 44)
                .accessibilityIdentifier("projection.toggleTodayMoney")

            Chart(chartPoints) { point in
                LineMark(
                    x: .value("Month", point.period),
                    y: .value("Balance", point.value),
                    series: .value("Series", point.series.rawValue)
                )
                .foregroundStyle(by: .value("Series", point.series.rawValue))
                .lineStyle(
                    point.series == .afterFees
                        ? StrokeStyle(lineWidth: 3)
                        : StrokeStyle(lineWidth: 3, dash: [7, 5])
                )

                PointMark(
                    x: .value("Month", point.period),
                    y: .value("Balance", point.value)
                )
                .foregroundStyle(by: .value("Series", point.series.rawValue))
                .symbol(by: .value("Series", point.series.rawValue))
                .accessibilityLabel("\(point.label), \(point.series.rawValue)")
                .accessibilityValue(IGCFormatters.gbp(point.value))
            }
            .chartForegroundStyleScale([
                ProjectionChartPoint.Series.afterFees.rawValue: Color.indigo,
                ProjectionChartPoint.Series.todayMoney.rawValue: Color.teal,
            ])
            .chartSymbolScale([
                ProjectionChartPoint.Series.afterFees.rawValue: .circle,
                ProjectionChartPoint.Series.todayMoney.rawValue: .diamond,
            ])
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(IGCFormatters.compactGBP(amount))
                        }
                    }
                }
            }
            .frame(minHeight: 260, idealHeight: 280, maxHeight: 320)
            .accessibilityLabel("Balance over time")
            .accessibilityHint("An audio graph of after-fee balances. Annual detail follows.")
            .transaction { transaction in
                if reduceMotion {
                    transaction.animation = nil
                }
            }

            Button("View annual detail", action: showAnnualDetail)
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 44)
                .accessibilityIdentifier("projection.viewAnnualDetail")
        }
    }

    private var assumptions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assumptions")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            LabeledContent("Preset", value: presetName)
            LabeledContent("Annual growth rate", value: IGCFormatters.percent(snapshot.input.apr))
            LabeledContent("Inflation", value: IGCFormatters.percent(snapshot.input.inflationRate))
            LabeledContent("Annual fee", value: IGCFormatters.percent(snapshot.input.annualFeeRate))
            LabeledContent("Compounding", value: snapshot.input.compoundFrequency.title)
            LabeledContent("Contribution timing", value: snapshot.input.timing.title)
        }
    }

    private var presetName: String {
        guard let id = snapshot.presetID else { return "Custom" }
        return PresetCatalog.preset(id).name
    }

    private var afterFeesBinding: Binding<Bool> {
        Binding(
            get: { showAfterFees },
            set: { newValue in
                if !newValue, !showTodayMoney { return }
                showAfterFees = newValue
            }
        )
    }

    private var todayMoneyBinding: Binding<Bool> {
        Binding(
            get: { showTodayMoney },
            set: { newValue in
                if !newValue, !showAfterFees { return }
                showTodayMoney = newValue
            }
        )
    }

    private func targetPresentation(_ status: TargetStatus) -> (title: String, symbol: String) {
        switch status {
        case .above: ("Above target", "arrow.up.circle.fill")
        case .below: ("Below target", "arrow.down.circle.fill")
        case .equal: ("Equal to target", "equal.circle.fill")
        }
    }

    private func financialFact(_ label: String, _ value: Double) -> some View {
        LabeledContent {
            Text(IGCFormatters.gbp(value))
                .monospacedDigit()
        } label: {
            Text(label)
        }
    }
}
