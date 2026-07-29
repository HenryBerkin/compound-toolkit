import SwiftUI

struct ScenarioStatusBanner: View {
    enum Kind {
        case success
        case failure
    }

    let kind: Kind
    let message: String
    var retry: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                message,
                systemImage: kind == .success
                    ? "checkmark.circle"
                    : "exclamationmark.triangle"
            )
            .font(.body)

            if let retry {
                Button("Try again", action: retry)
                    .frame(minHeight: 44)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(kind == .success ? Color.green.opacity(0.10) : Color.red.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.separator)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
    }
}
