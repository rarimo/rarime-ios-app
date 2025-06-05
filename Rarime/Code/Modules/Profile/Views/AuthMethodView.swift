import SwiftUI

struct AuthMethodView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Auth Method"),
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                AuthMethodItem(
                    isOn: Binding(
                        get: { securityManager.faceIdState == .enabled },
                        set: { $0 ? securityManager.enableFaceId() : securityManager.disableFaceId() }
                    ),
                    icon: .userFocus,
                    label: String(localized: "Face ID")
                )
                .disabled(securityManager.passcodeState == .disabled)
                AuthMethodItem(
                    isOn: Binding(
                        get: { securityManager.passcodeState == .enabled },
                        set: { $0 ? securityManager.enablePasscode() : securityManager.disablePasscode() }
                    ),
                    icon: .password,
                    label: String(localized: "Passcode")
                )
            }
        }
    }
}

private struct AuthMethodItem: View {
    @Binding var isOn: Bool
    let icon: ImageResource
    let label: String

    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
                .iconMedium()
                .padding(6)
                .background(.bgComponentPrimary, in: Circle())
                .foregroundStyle(.textPrimary)
            Text(label)
                .subtitle6()
                .foregroundStyle(.textPrimary)
            Spacer()
            AppToggle(isOn: $isOn)
        }
        .padding(16)
        .background(.bgComponentPrimary, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AuthMethodView(onBack: {})
        .environmentObject(SecurityManager())
}
