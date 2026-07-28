import Foundation

enum IGCFormatters {
    private static let locale = Locale(identifier: "en_GB")

    static func gbp(_ value: Double) -> String {
        let rounded = roundForDisplay(value, scale: 2)
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = Currency.GBP.rawValue
        formatter.currencySymbol = "£"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSDecimalNumber(decimal: rounded)) ?? "£—"
    }

    static func percent(_ decimalRate: Double) -> String {
        let rounded = roundForDisplay(decimalRate * 100, scale: 2)
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return "\(formatter.string(from: NSDecimalNumber(decimal: rounded)) ?? "—")%"
    }

    static func compactGBP(_ value: Double) -> String {
        let magnitude = abs(value)
        if magnitude >= 1_000_000 {
            return String(format: "£%.1fM", locale: locale, value / 1_000_000)
        }
        if magnitude >= 1_000 {
            return String(format: "£%.0fK", locale: locale, value / 1_000)
        }
        return gbp(value)
    }

    static func targetGapText(_ analysis: TargetAnalysis) -> String {
        switch analysis.status {
        case .equal:
            return "Projected value equals the target in today’s money."
        case .above, .below:
            let direction = analysis.status == .above ? "above" : "below"
            if abs(analysis.rawGap) < 0.005 {
                return "Less than £0.01 \(direction) the target in today’s money."
            }
            return "\(gbp(abs(analysis.rawGap))) \(direction) the target in today’s money."
        }
    }

    static func duration(years: Int, months: Int) -> String {
        let yearPart = years == 0 ? nil : "\(years) \(years == 1 ? "year" : "years")"
        let monthPart = months == 0 ? nil : "\(months) \(months == 1 ? "month" : "months")"
        return [yearPart, monthPart].compactMap { $0 }.joined(separator: ", ")
    }

    private static func roundForDisplay(_ value: Double, scale: Int) -> Decimal {
        guard value.isFinite,
              var decimal = Decimal(string: String(value), locale: Locale(identifier: "en_US_POSIX")) else {
            return .nan
        }
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, scale, .plain)
        return rounded
    }
}
struct ProjectionChartPoint: Identifiable, Equatable, Sendable {
    enum Series: String, CaseIterable, Sendable {
        case afterFees = "After fees"
        case todayMoney = "After fees in today’s money"
    }

    var id: String { "\(series.rawValue)-\(period)" }
    let period: Int
    let label: String
    let series: Series
    let value: Double
}

enum ProjectionPresenter {
    static func chartPoints(
        input: CalculationInput,
        result: CalculationResult
    ) -> [ProjectionChartPoint] {
        var points: [ProjectionChartPoint] = [
            .init(period: 0, label: "Start", series: .afterFees, value: input.principal),
            .init(period: 0, label: "Start", series: .todayMoney, value: input.principal),
        ]
        for row in result.annualRows {
            let label = row.isPartial ? "Year \(row.year), partial" : "Year \(row.year)"
            points.append(.init(
                period: row.endPeriod,
                label: label,
                series: .afterFees,
                value: row.endingBalanceAfterFees
            ))
            points.append(.init(
                period: row.endPeriod,
                label: label,
                series: .todayMoney,
                value: row.realEndingBalanceAfterFees
            ))
        }
        return points
    }

    static func factualSummary(
        input: CalculationInput,
        result: CalculationResult
    ) -> String {
        "From \(IGCFormatters.gbp(input.principal)), the projection reaches \(IGCFormatters.gbp(result.finalBalanceAfterFees)) after fees, or \(IGCFormatters.gbp(result.finalBalanceAfterFeesReal)) in today’s money, over \(IGCFormatters.duration(years: input.years, months: input.months))."
    }
}
