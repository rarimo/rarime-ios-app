import SwiftUI

struct ExportKeysView: View {
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Export Keys"),
            onBack: onBack
        ) {
            Text("Export Keys")
        }
    }
}

#Preview {
    ExportKeysView(onBack: {})
}
