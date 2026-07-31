import SwiftUI

/// A label-and-value row that stacks vertically at accessibility text sizes.
///
/// `LabeledContent` keeps the label and value side by side and narrows the value
/// column until it breaks, which wraps a figure mid-number — "£10,00" above
/// "0.00". A split amount reads as a different amount, so at accessibility sizes
/// the value moves to its own line instead.
struct FinancialFactRow: View {
    let label: String
    let value: String
    var isEmphasised = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                    valueText
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LabeledContent {
                    valueText
                } label: {
                    Text(label)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var valueText: some View {
        Text(value)
            .monospacedDigit()
            .fontWeight(isEmphasised ? .semibold : .regular)
            .fixedSize(horizontal: false, vertical: true)
    }
}
