import SwiftUI

struct AppTextField<Hint: View, Action: View>: View {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.controlSize) var controlSize

    @Binding var text: String
    @Binding var errorMessage: String

    var label: String?
    var placeholder: String
    var keyboardType: UIKeyboardType

    @ViewBuilder let action: () -> Action
    @ViewBuilder let hint: () -> Hint

    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        errorMessage: Binding<String>,
        label: String? = nil,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        @ViewBuilder action: @escaping () -> Action = { EmptyView() },
        @ViewBuilder hint: @escaping () -> Hint = { EmptyView() }
    ) {
        self._text = text
        self._errorMessage = errorMessage

        self.label = label
        self.placeholder = placeholder
        self.keyboardType = keyboardType

        self.action = action
        self.hint = hint
    }

    var isError: Bool {
        !errorMessage.isEmpty
    }

    var borderColor: Color {
        if !isEnabled { return .componentDisabled }
        if isError { return .errorMain }
        return isFocused ? .componentPressed : .componentPrimary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label {
                Text(label)
                    .subtitle4()
                    .foregroundStyle(isEnabled ? .textPrimary : .textDisabled)
            }
            HStack(spacing: 8) {
                TextField(
                    self.placeholder,
                    text: self.$text
                )
                .keyboardType(keyboardType)
                .focused($isFocused)
                .disabled(!isEnabled)
                .body3()
                .frame(height: 20)
                .padding(.vertical, controlSize == .large ? 18 : 14)
                .onTapGesture { isFocused = true }
                .onChange(of: text) { _ in
                    self.errorMessage = ""
                }
                action()
            }
            .padding(.horizontal, 16)
            .background(isEnabled ? .clear : .componentDisabled)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )

            if isError {
                HStack(spacing: 8) {
                    Image(Icons.info).iconSmall()
                    Text(self.errorMessage).caption2()
                }
                .foregroundStyle(.errorMain)
            } else {
                hint()
            }
        }
    }
}

private struct PreviewView: View {
    @State private var text = ""
    @State private var errorMessage = "Some error message"

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            AppTextField(
                text: self.$text,
                errorMessage: .constant(""),
                label: "Regular",
                placeholder: "Enter text here",
                action: {
                    Image(Icons.qrCode)
                        .iconMedium()
                        .foregroundStyle(.textSecondary)
                }
            ) {
                HStack {
                    Text(verbatim: "Some hint text").caption2()
                    Spacer()
                    Image(Icons.info).iconSmall()
                }
            }
            AppTextField(
                text: self.$text,
                errorMessage: self.$errorMessage,
                label: "Error",
                placeholder: "Enter text here"
            )
            AppTextField(
                text: self.$text,
                errorMessage: .constant(""),
                label: "Disabled large",
                placeholder: "Enter text here"
            )
            .disabled(true)
            .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPure)
    }
}

#Preview {
    PreviewView()
}
