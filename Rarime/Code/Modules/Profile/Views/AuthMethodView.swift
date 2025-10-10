import SwiftUI

struct AuthMethodView: View {
    @EnvironmentObject private var securityManager: SecurityManager

    let onBack: () -> Void

    @State private var isPasscodeSheetShown = false
    @State private var isFaceIdAlertShown = false
    @State private var isFaceIdNotAvailableError = false

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Auth Method"),
            onBack: onBack
        ) {
            VStack(spacing: 12) {
                AuthMethodItem(
                    isOn: Binding(
                        get: { securityManager.passcodeState == .enabled },
                        set: { _ in isPasscodeSheetShown = true }
                    ),
                    icon: .hashtag,
                    label: String(localized: "Passcode")
                )
                .dynamicSheet(isPresented: $isPasscodeSheetShown) {
                    PasscodeView(onFinish: { isPasscodeSheetShown = false })
                        .environmentObject(securityManager)
                }
                AuthMethodItem(
                    isOn: Binding(
                        get: { securityManager.faceIdState == .enabled },
                        set: { $0 ? enableFaceId() : securityManager.disableFaceId() }
                    ),
                    icon: .userFocus,
                    label: String(localized: "Face ID")
                )
                .disabled(securityManager.passcodeState != .enabled)
                .alert(
                    isFaceIdNotAvailableError ? "Face ID Disabled" : "Authentication Failed",
                    isPresented: $isFaceIdAlertShown,
                    actions: {
                        Button("Cancel", role: .cancel) {}
                        if isFaceIdNotAvailableError {
                            Button("Open Settings") {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            }
                        }
                    },
                    message: {
                        isFaceIdNotAvailableError
                            ? Text("Enable Face ID in Settings > Rarimo.")
                            : Text("Could not authenticate with Face ID. Please try again.")
                    }
                )
            }
        }
    }

    private func enableFaceId() {
        FaceIdAuth.shared.authenticate(
            onSuccess: { securityManager.enableFaceId() },
            onFailure: {
                isFaceIdNotAvailableError = false
                isFaceIdAlertShown = true
            },
            onNotAvailable: {
                isFaceIdNotAvailableError = true
                isFaceIdAlertShown = true
            }
        )
    }
}

private struct PasscodeView: View {
    @EnvironmentObject private var securityManager: SecurityManager

    let onFinish: () -> Void

    @State private var isRepeat = false

    @State private var passcode = ""
    @State private var passcodeError = ""

    @State private var repeatPasscode = ""
    @State private var repeatPasscodeError = ""

    var body: some View {
        VStack {
            Text(isRepeat ? "Repeat Passcode" : "Enter Passcode")
                .h2()
                .foregroundStyle(.textPrimary)
            Spacer()
            if isRepeat {
                PasscodeFieldView(
                    passcode: $repeatPasscode,
                    errorMessage: $repeatPasscodeError,
                    onFill: onRepeatPasscodeFill
                )
            } else {
                PasscodeFieldView(
                    passcode: $passcode,
                    errorMessage: $passcodeError,
                    onFill: onPasscodeFill
                )
            }
        }
        .padding(.top, 96)
    }

    private func onPasscodeFill() {
        if securityManager.passcodeState == .disabled {
            isRepeat = true
            return
        }

        if passcode == securityManager.passcode {
            securityManager.disablePasscode()
            onFinish()
        } else {
            passcodeError = String(localized: "Incorrect passcode")
            FeedbackGenerator.shared.notify(.error)
        }
    }

    private func onRepeatPasscodeFill() {
        if passcode == repeatPasscode {
            securityManager.enablePasscode(passcode)
            onFinish()
        } else {
            repeatPasscodeError = String(localized: "Passcodes do not match")
            FeedbackGenerator.shared.notify(.error)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                repeatPasscode = ""
                repeatPasscodeError = ""

                passcode = ""
                isRepeat = false
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
                .foregroundStyle(.textPrimary)
            Text(label)
                .subtitle6()
                .foregroundStyle(.textPrimary)
            Spacer()
            AppToggle(isOn: $isOn)
        }
        .padding(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.bgComponentPrimary)
        )
    }
}

#Preview {
    AuthMethodView(onBack: {})
        .environmentObject(SecurityManager())
}
