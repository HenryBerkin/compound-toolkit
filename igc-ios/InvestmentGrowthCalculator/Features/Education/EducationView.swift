import SwiftUI

enum EducationArticle: String, Hashable, Identifiable, Sendable {
    case understanding
    case calculations
    case exclusions
    case disclaimer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .understanding: "Understanding your projection"
        case .calculations: "How calculations work"
        case .exclusions: "What this projection excludes"
        case .disclaimer: "Projection disclaimer"
        }
    }

    var sections: [EducationSection] {
        switch self {
        case .understanding:
            [
                EducationSection(
                    heading: "An illustrative result",
                    paragraphs: [
                        "IGC uses the values you enter to produce one deterministic projection. It shows what the calculation produces when those assumptions remain constant; it does not estimate how likely that result is.",
                        "Final balance after fees is shown in future pounds. The separate today’s-money value uses your inflation assumption to express purchasing power at the end of the selected duration.",
                    ]
                ),
                EducationSection(
                    heading: "Reading the projection",
                    paragraphs: [
                        "Compare the after-fee result with the before-fee balance to understand fee drag. Contributions and calculated growth are shown separately, and annual detail provides the complete year-by-year alternative to the chart.",
                        "A target is an optional comparison in today’s money. Above, below or equal describes only the mathematical comparison; it is not a judgement about suitability or progress.",
                    ]
                ),
            ]
        case .calculations:
            [
                EducationSection(
                    heading: "Monthly calculation",
                    paragraphs: [
                        "The calculation proceeds month by month for the duration you select. Annual detail groups those internal monthly periods, including a final partial year.",
                        "The annual growth rate (APR) is converted to an effective monthly rate according to the selected daily, monthly, quarterly or annual compounding frequency.",
                    ]
                ),
                EducationSection(
                    heading: "Contributions and timing",
                    paragraphs: [
                        "Weekly contributions are converted using the amount × 52 ÷ 12. Annual contributions are converted using the amount ÷ 12. Monthly contributions use the amount entered.",
                        "With start-of-period timing, the monthly-equivalent contribution is added before that period’s growth and fee. With end-of-period timing, growth and the asset-based fee are applied before the contribution is added.",
                    ]
                ),
                EducationSection(
                    heading: "Growth, fees and inflation",
                    paragraphs: [
                        "In each monthly period, growth occurs before the asset-based fee deduction. The fee is applied to the post-growth balance; it is not subtracted from APR.",
                        "Today’s-money values divide the relevant future amount by the effect of your inflation assumption over the elapsed time.",
                    ]
                ),
                EducationSection(
                    heading: "Constant assumptions",
                    paragraphs: [
                        "Rates and contributions remain constant throughout this deterministic projection. The calculation does not create a variable market path or probability range.",
                    ]
                ),
            ]
        case .exclusions:
            [
                EducationSection(
                    heading: "Not modelled",
                    paragraphs: [
                        "The projection does not model taxes, market volatility or the order of returns, changing inflation, contribution limits, platform or transaction charges beyond the annual fee you enter, pension or ISA rules, withdrawals, or investment losses along a market path.",
                        "It does not connect to an account, use live market data, select an investment, or assess whether an assumption or outcome is suitable for you.",
                    ]
                ),
                EducationSection(
                    heading: "Why actual outcomes differ",
                    paragraphs: [
                        "Actual contributions, charges, inflation and market returns can change over time. Actual outcomes may be higher or lower than this constant-assumption illustration.",
                    ]
                ),
            ]
        case .disclaimer:
            [
                EducationSection(
                    heading: "Illustrative projection",
                    paragraphs: [EducationContent.projectionDisclaimer]
                ),
            ]
        }
    }
}

struct EducationSection: Identifiable, Hashable, Sendable {
    let heading: String
    let paragraphs: [String]

    var id: String { heading }
}

enum EducationContent {
    static let projectionDisclaimer = "IGC creates an illustrative projection from the assumptions you enter. It is not financial advice, a forecast, or a recommendation. Rates and contributions are held constant. The calculation does not model taxes, market volatility or the order of returns, changing inflation, contribution limits, platform or transaction charges beyond the annual fee you enter, pension or ISA rules, withdrawals, or investment losses along a market path. Actual outcomes may be higher or lower."
}

enum GlossaryTerm: Int, CaseIterable, Identifiable, Hashable, Sendable {
    case annualGrowthRate
    case compounding
    case inflation
    case annualFee
    case afterFees
    case todaysMoney
    case contributionFrequency
    case contributionTiming
    case presetAndCustom
    case target

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .annualGrowthRate: "Annual growth rate (APR)"
        case .compounding: "Compounding"
        case .inflation: "Inflation"
        case .annualFee: "Annual fee"
        case .afterFees: "After fees"
        case .todaysMoney: "Today’s money / purchasing power"
        case .contributionFrequency: "Contribution frequency"
        case .contributionTiming: "Contribution timing"
        case .presetAndCustom: "Preset and Custom"
        case .target: "Target"
        }
    }

    var definition: String {
        switch self {
        case .annualGrowthRate:
            "The nominal yearly growth assumption before fees and inflation. IGC converts APR according to the compounding frequency you select."
        case .compounding:
            "How the annual growth rate and annual fee are converted into monthly effects. IGC offers daily, monthly, quarterly and annual conversion conventions."
        case .inflation:
            "The annual assumption used to express a future amount in today’s purchasing power. It does not change the nominal future-pound balance."
        case .annualFee:
            "An asset-based yearly charge assumption. IGC converts it according to the selected compounding frequency and deducts it after growth in each monthly period."
        case .afterFees:
            "The projection path after deducting the annual fee you enter. The difference from the before-fee path can exceed fees paid because deducted fees do not receive later growth."
        case .todaysMoney:
            "A future amount adjusted using the inflation assumption so it can be read in terms of purchasing power at the start of the projection."
        case .contributionFrequency:
            "How often the amount you enter is contributed. Weekly amounts use × 52 ÷ 12 each month, monthly amounts are unchanged, and annual amounts use ÷ 12."
        case .contributionTiming:
            "Whether each monthly-equivalent contribution is added at the start of the period before growth and fees, or at the end after growth and fees."
        case .presetAndCustom:
            "A preset deliberately applies a bundled example for growth, inflation, fee and compounding. Custom means those assumptions are not currently matched to a selected preset."
        case .target:
            "An optional amount in today’s money used only to compare with the final after-fee today’s-money value. It does not change the calculation."
        }
    }
}

struct EducationView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(
                    EducationArticle.understanding.title,
                    value: EducationRoute.article(.understanding)
                )
                .accessibilityIdentifier("education.understanding")

                NavigationLink(
                    EducationArticle.calculations.title,
                    value: EducationRoute.article(.calculations)
                )
                .accessibilityIdentifier("education.calculations")

                NavigationLink("Glossary", value: EducationRoute.glossary)
                .accessibilityIdentifier("education.glossary")

                NavigationLink(
                    EducationArticle.exclusions.title,
                    value: EducationRoute.article(.exclusions)
                )
                .accessibilityIdentifier("education.exclusions")

                NavigationLink(
                    EducationArticle.disclaimer.title,
                    value: EducationRoute.article(.disclaimer)
                )
                .accessibilityIdentifier("education.disclaimer")
            } footer: {
                Text("All Education content is bundled with IGC and available offline.")
            }
        }
        .navigationTitle("Education")
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}

struct EducationArticleView: View {
    let article: EducationArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(article.sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.heading)
                            .font(.title2.bold())
                            .accessibilityAddTraits(.isHeader)
                        ForEach(Array(section.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                            Text(paragraph)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("education.article.\(article.rawValue)")
    }
}

struct GlossaryView: View {
    var body: some View {
        List(GlossaryTerm.allCases) { term in
            NavigationLink(term.title, value: EducationRoute.glossaryTerm(term))
            .accessibilityIdentifier("education.glossary.\(term.rawValue)")
        }
        .navigationTitle("Glossary")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}

struct GlossaryTermView: View {
    let term: GlossaryTerm

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(term.title)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(term.definition)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(term.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContextualEducationSheet: View {
    let article: EducationArticle

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            EducationArticleView(article: article)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}
