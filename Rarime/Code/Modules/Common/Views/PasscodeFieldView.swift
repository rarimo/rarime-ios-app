import SwiftUI

private let passcodeLength: Int = 4

struct PasscodeFieldView: View {
    @Binding var passcode: String
    @Binding var errorMessage: String
    var onFill: () -> Void

    init(passcode: Binding<String>, errorMessage: Binding<String> = .constant(""), onFill: @escaping () -> Void = {}) {
        self._errorMessage = errorMessage
        self._passcode = passcode
        self.onFill = onFill
    }

    func handleInput(_ input: String) {
        if passcode.count >= passcodeLength { return }

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

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .caption2()
                    .foregroundColor(.errorMain)
                    .padding(.top, 64)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(minHeight: 90)
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
                    }
                }
            }
            HStack(spacing: 0) {
                Spacer().frame(maxWidth: .infinity)
                InputButton(action: { handleInput("0") }) {
                    Text(String("0")).subtitle2()
                }
                InputButton(action: {
                    if passcode.isEmpty { return }

                    passcode.removeLast()
                    errorMessage = ""
                }) {
                    Image(Icons.backspace).iconMedium()
                }
            }
        }
    }
}

private struct InputButton<Content: View>: View {
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
