import SwiftUI

private let passcodeLength: Int = 4

struct PasscodeFieldView: View {
    @Environment(\.isEnabled) var isEnabled

    @Binding var passcode: String
    @Binding var errorMessage: String
    var isFaceIdEnabled: Bool
    var onFill: () -> Void
    var onFaceIdClick: () -> Void

    init(
        passcode: Binding<String>,
        errorMessage: Binding<String> = .constant(""),
        isFaceIdEnabled: Bool = false,
        onFill: @escaping () -> Void = {},
        onFaceIdClick: @escaping () -> Void = {}
    ) {
        self._errorMessage = errorMessage
        self._passcode = passcode
        self.isFaceIdEnabled = isFaceIdEnabled
        self.onFill = onFill
        self.onFaceIdClick = onFaceIdClick
    }

    func handleInput(_ input: String) {
        if !isEnabled || passcode.count >= passcodeLength { return }

        passcode += input
        errorMessage = ""

        if passcode.count == passcodeLength {
            onFill()
        }
    }

    var body: some View {
        VStack(spacing: 120) {
            passcodeView
            numberKeyboard
        }
    }

    var passcodeView: some View {
        ZStack {
            HStack {
                ForEach(0 ..< passcodeLength, id: \.self) { index in
                    ZStack {
                        Circle()
                            .frame(height: 16)
                            .foregroundColor(index < passcode.count ? errorMessage.isEmpty ? .primaryMain : .errorMain : .componentPrimary)
                    }
                    .padding(16)
                }
            }

            Text(errorMessage)
                .subtitle4()
                .foregroundColor(.errorMain)
                .frame(minWidth: 260, minHeight: 40)
                .background(.errorLighter, in: RoundedRectangle(cornerRadius: 100))
                .padding(.top, 180)
                .multilineTextAlignment(.center)
                .opacity(errorMessage.isEmpty ? 0 : 1)
        }
        .frame(minHeight: 90)
        .opacity(isEnabled ? 1 : 0)
    }

    var numberKeyboard: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 3) { row in
                HStack(spacing: 0) {
                    ForEach(1 ..< 4) { column in
                        let value = String(row * 3 + column)
                        InputButton(action: { handleInput(value) }) {
                            Text(value).subtitle2()
                        }
                        .disabled(!isEnabled)
                    }
                }
            }
            HStack(spacing: 0) {
                if isFaceIdEnabled {
                    InputButton(action: onFaceIdClick) {
                        Image(Icons.userFocus).square(24)
                    }
                    .disabled(!isEnabled)
                } else {
                    Spacer().frame(maxWidth: .infinity)
                }
                InputButton(action: { handleInput("0") }) {
                    Text(String("0")).subtitle2()
                }
                .disabled(!isEnabled)
                InputButton(action: {
                    if passcode.isEmpty { return }

                    passcode.removeLast()
                    errorMessage = ""
                }) {
                    Image(Icons.backspace).iconMedium()
                }
                .disabled(!isEnabled)
            }
        }
    }
}

private struct InputButton<Content: View>: View {
    @Environment(\.isEnabled) var isEnabled

    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: {
            action()
            FeedbackGenerator.shared.impact(.light)
        }) {
            content
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .foregroundStyle(.textPrimary)
        }
        .disabled(!isEnabled)
    }
}

private struct PreviewView: View {
    @State var passcode: String = "12"
    @State var errorMessage: String = "Some error message"

    var body: some View {
        PasscodeFieldView(passcode: $passcode, errorMessage: $errorMessage)
    }
}

#Preview {
    PreviewView()
}
