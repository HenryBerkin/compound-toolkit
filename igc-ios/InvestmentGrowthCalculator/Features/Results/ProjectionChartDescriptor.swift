import Accessibility
import Foundation
import SwiftUI

/// Supplies the VoiceOver chart description and Audio Graph for the projection chart.
///
/// Without this, VoiceOver can only step through individual marks: there is no
/// "Describe Chart" rotor action and no audio graph, however the chart is labelled.
/// The projection chart is the one screen where a visual carries the meaning, so the
/// non-visual alternative has to be a real chart description rather than a claim.
struct ProjectionChartDescriptor: AXChartDescriptorRepresentable {
    let points: [ProjectionChartPoint]
    let durationDescription: String

    func makeChartDescriptor() -> AXChartDescriptor {
        let values = points.map(\.value)
        let periods = points.map { Double($0.period) }

        let lowestValue = min(0, values.min() ?? 0)
        let highestValue = max(lowestValue, values.max() ?? 0)
        let earliestPeriod = periods.min() ?? 0
        let latestPeriod = max(earliestPeriod, periods.max() ?? 0)

        let xAxis = AXNumericDataAxisDescriptor(
            title: "Month",
            range: earliestPeriod...latestPeriod,
            gridlinePositions: []
        ) { value in
            value == 0 ? "Start" : "Month \(Int(value.rounded()))"
        }

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Balance",
            range: lowestValue...highestValue,
            gridlinePositions: []
        ) { value in
            IGCFormatters.gbp(value)
        }

        // Iterate the declared cases rather than grouping into a dictionary, so the
        // series order VoiceOver reads is stable between launches.
        let series = ProjectionChartPoint.Series.allCases.compactMap { seriesCase -> AXDataSeriesDescriptor? in
            let seriesPoints = points.filter { $0.series == seriesCase }
            guard !seriesPoints.isEmpty else { return nil }
            return AXDataSeriesDescriptor(
                name: seriesCase.rawValue,
                isContinuous: true,
                dataPoints: seriesPoints.map { point in
                    AXDataPoint(
                        x: Double(point.period),
                        y: point.value,
                        additionalValues: [],
                        label: point.label
                    )
                }
            )
        }

        return AXChartDescriptor(
            title: "Balance over time",
            summary: summary,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: series
        )
    }

    func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
        let updated = makeChartDescriptor()
        descriptor.summary = updated.summary
        descriptor.xAxis = updated.xAxis
        descriptor.yAxis = updated.yAxis
        descriptor.series = updated.series
    }

    private var summary: String {
        let names = ProjectionChartPoint.Series.allCases
            .filter { seriesCase in points.contains { $0.series == seriesCase } }
            .map(\.rawValue)
        let seriesDescription = names.isEmpty
            ? "no series"
            : names.joined(separator: " and ")
        return "Projected balance at the end of each year over \(durationDescription), "
            + "showing \(seriesDescription)."
    }
}
