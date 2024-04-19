import SwiftUI

struct LanguageView: View {
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Language"),
            onBack: onBack
        ) {
            Text("Language")
        }
    }
}

#Preview {
    LanguageView(onBack: {})
}
