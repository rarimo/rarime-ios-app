import SwiftUI

private enum FaceIdAuthError: Error {
    case notAvailable
    case failed
}

struct EnableFaceIdView: View {
    @EnvironmentObject private var securityManager: SecurityManager
    @State private var isAlertShown = false
    @State private var isNotAvailableError = false

    var body: some View {
        EnableLayoutView(
            icon: Icons.userFocus,
            title: String(localized: "Enable\nFace ID"),
            description: String(localized: "Enable Face ID Login"),
            enableAction: {
                FaceIdAuth.shared.authenticate(
                    onSuccess: { withAnimation { securityManager.enableFaceId() } },
                    onFailure: {
                        isNotAvailableError = false
                        isAlertShown = true
                    },
                    onNotAvailable: {
                        isNotAvailableError = true
                        isAlertShown = true
                    }
                )
            },
            skipAction: { withAnimation { securityManager.disableFaceId() } }
        )
        .alert(
            isNotAvailableError ? "Face ID Disabled" : "Authentication Failed",
            isPresented: $isAlertShown,
            actions: {
                Button("Cancel", role: .cancel) {}
                if isNotAvailableError {
                    Button("Open Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            },
            message: {
                isNotAvailableError
                    ? Text("Enable Face ID in Settings > RariMe.")
                    : Text("Could not authenticate with Face ID. Please try again.")
            }
        )
    }
}

#Preview {
    EnableFaceIdView()
        .environmentObject(SecurityManager())
}
