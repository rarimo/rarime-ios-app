import SwiftUI

struct AuthMethodView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Auth Method"),
            onBack: onBack
        ) {
            VStack(spacing: 24) {
                AuthMethodRow(
                    isOn: Binding(
                        get: { securityManager.faceIdState == .enabled },
                        set: { $0 ? securityManager.enableFaceId() : securityManager.disableFaceId() }
                    ),
                    icon: Icons.userFocus,
                    label: String(localized: "Face ID")
                )
                AuthMethodRow(
                    isOn: Binding(
                        get: { securityManager.passcodeState == .enabled },
                        set: { $0 ? securityManager.enablePasscode() : securityManager.disablePasscode() }
                    ),
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
        .environmentObject(SecurityManager())
}
