import SwiftUI

struct EducationView: View {
    var body: some View {
        List {
            Section("Understanding your projection") {
                Text("IGC uses the assumptions you enter to calculate one illustrative, constant-rate projection.")
                Text("Today’s-money values adjust future amounts using your inflation assumption.")
                Text("Fees are modelled as an asset-based drag after growth in each monthly period.")
            }
            Section("What this slice excludes") {
                Text("It does not model taxes, market volatility, withdrawals, live prices or personal recommendations.")
            }
        }
        .navigationTitle("Education")
    }
}
