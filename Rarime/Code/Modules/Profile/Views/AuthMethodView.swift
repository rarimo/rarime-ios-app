import SwiftUI

struct AuthMethodView: View {
    let onBack: () -> Void

    // TODO: Move to ViewModel
    @State private var isFaceIdEnabled = false
    @State private var isPasscodeEnabled = false

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Auth Method"),
            onBack: onBack
        ) {
            VStack(spacing: 24) {
                AuthMethodRow(
                    isOn: $isFaceIdEnabled,
                    icon: Icons.userFocus,
                    label: String(localized: "Face ID")
                )
                AuthMethodRow(
                    isOn: $isPasscodeEnabled,
                    icon: Icons.password,
                    label: String(localized: "Passcode")
                )
            }
        }
    }
}

private struct AuthMethodRow: View {
    @Binding var isOn: Bool
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .iconMedium()
                .padding(6)
                .background(.componentPrimary, in: Circle())
                .foregroundStyle(.textPrimary)
            Text(label)
                .subtitle4()
                .foregroundStyle(.textPrimary)
            Spacer()
            AppToggle(isOn: $isOn)
        }
    }
}

#Preview {
    AuthMethodView(onBack: {})
}
