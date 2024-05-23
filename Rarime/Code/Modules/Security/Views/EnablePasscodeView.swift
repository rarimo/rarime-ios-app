import SwiftUI

private enum PasscodeRoute: Hashable {
    case enterPasscode, repeatPasscode
}

struct EnablePasscodeView: View {
    @EnvironmentObject private var securityManager: SecurityManager

    @State private var path: [PasscodeRoute] = []

    @State private var passcode = ""
    @State private var repeatPasscode = ""
    @State private var repeatPasscodeError = ""

    var body: some View {
        NavigationStack(path: $path) {
            EnableLayoutView(
                icon: Icons.password,
                title: String(localized: "Enable\nPasscode"),
                description: String(localized: "Enable Passcode Login"),
                enableAction: { path.append(.enterPasscode) },
                skipAction: { withAnimation { securityManager.disablePasscode() } }
            )
            .navigationDestination(for: PasscodeRoute.self) { route in
                switch route {
                case .enterPasscode:
                    PasscodeView(
                        passcode: $passcode,
                        title: "Enter Passcode",
                        onFill: { path.append(.repeatPasscode) },
                        onClose: {
                            passcode = ""
                            path.removeLast()
                        }
                    )
                case .repeatPasscode:
                    PasscodeView(
                        passcode: $repeatPasscode,
                        errorMessage: $repeatPasscodeError,
                        title: "Repeat Passcode",
                        onFill: {
                            if passcode == repeatPasscode {
                                withAnimation {
                                    securityManager.setPasscode(passcode)
                                }
                            } else {
                                repeatPasscodeError = String(localized: "Passcodes do not match")
                                FeedbackGenerator.shared.notify(.error)
                            }
                        },
                        onClose: {
                            passcode = ""
                            repeatPasscode = ""
                            repeatPasscodeError = ""
                            path.removeLast()
                        }
                    )
                }
            }
        }
    }
}

struct PasscodeView: View {
    @Binding var passcode: String
    @Binding var errorMessage: String
    let title: LocalizedStringResource
    let onFill: () -> Void
    let onClose: () -> Void
    
    let isClosable: Bool

    init(
        passcode: Binding<String>,
        errorMessage: Binding<String> = .constant(""),
        title: LocalizedStringResource,
        onFill: @escaping () -> Void,
        onClose: @escaping () -> Void,
        isClosable: Bool = true
    ) {
        self._passcode = passcode
        self._errorMessage = errorMessage
        self.title = title
        self.onFill = onFill
        self.onClose = onClose
        self.isClosable = isClosable
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if isClosable {
                Button(action: onClose) {
                    Image(Icons.close)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                }
            }
            VStack {
                Text(title)
                    .h4()
                    .foregroundStyle(.textPrimary)
                Spacer()
                PasscodeFieldView(
                    passcode: $passcode,
                    errorMessage: $errorMessage,
                    onFill: onFill
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 150)
            .padding(.bottom, 16)
            .padding(.horizontal, 8)
        }
        .background(.backgroundPure)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    EnablePasscodeView()
        .environmentObject(SecurityManager())
}
