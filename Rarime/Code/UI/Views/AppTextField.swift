import SwiftUI

struct AppTextField<Hint: View, Action: View>: View {
    @Binding var text: String
    @Binding var errorMessage: String

    var label: LocalizedStringResource?
    var placeholder: LocalizedStringKey

    @ViewBuilder let action: Action
    @ViewBuilder let hint: Hint

    var isError: Bool {
        !errorMessage.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label {
                Text(label)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
            }
            HStack(spacing: 8) {
                TextField(
                    self.placeholder,
                    text: self.$text
                )
                .body3()
                .frame(height: 20)
                .onChange(of: text) { _ in
                    self.errorMessage = ""
                }
                action
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.componentPrimary, lineWidth: 1)
            )

            if isError {
                HStack(spacing: 8) {
                    Image(Icons.info).iconSmall()
                    Text(self.errorMessage).caption2()
                }
                .foregroundStyle(.errorMain)
            } else {
                hint
            }
        }
    }
}

private struct PreviewView: View {
    @State private var text = ""
    @State private var errorMessage = "Some error message"

    var body: some View {
        VStack(alignment: .leading) {
            AppTextField(
                text: self.$text,
                errorMessage: self.$errorMessage,
                label: "Field Label",
                placeholder: "Enter text here",
                action: {
                    Image(Icons.qrCode)
                        .iconMedium()
                        .foregroundStyle(.textSecondary)
                }
            ) {
                HStack {
                    Text("Some hint text").caption2()
                    Spacer()
                    Image(Icons.info).iconSmall()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPure)
    }
}

#Preview {
    PreviewView()
}
