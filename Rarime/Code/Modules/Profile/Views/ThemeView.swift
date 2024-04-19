import SwiftUI

struct ThemeView: View {
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Theme"),
            onBack: onBack
        ) {
            Text("Theme")
        }
    }
}

#Preview {
    ThemeView(onBack: {})
}
