import SwiftUI

struct AuthMethodView: View {
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Auth Method"),
            onBack: onBack
        ) {
            Text("Auth Method")
        }
    }
}

#Preview {
    AuthMethodView(onBack: {})
}
