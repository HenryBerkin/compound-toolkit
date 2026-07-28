import SwiftUI

struct SavedScenariosView: View {
    let goToCalculator: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No saved scenarios", systemImage: "bookmark")
        } description: {
            Text("View a projection, then save it in a later app delivery.")
        } actions: {
            Button("Go to Calculator", action: goToCalculator)
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 44)
                .accessibilityIdentifier("saved.goToCalculator")
        }
        .navigationTitle("Saved scenarios")
    }
}
