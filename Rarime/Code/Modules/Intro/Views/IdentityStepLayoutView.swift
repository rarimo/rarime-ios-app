import SwiftUI

let totalSteps = 2

struct IdentityStepLayoutView<Content: View, NextButton: View>: View {
    let title: String
    let onBack: () -> Void

    @ViewBuilder var nextButton: () -> NextButton
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Button(action: onBack) {
                        Image(Icons.caretLeft)
                            .iconMedium()
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 32) {
                    Text(title)
                        .subtitle2()
                        .foregroundColor(.textPrimary)
                    content()
                }
                .padding(.vertical, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            Spacer()
            HStack {
                nextButton()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.backgroundPure)
        }
        .background(.backgroundPrimary)
    }
}

#Preview {
    IdentityStepLayoutView(
        title: "New recovery phrase",
        onBack: {},
        nextButton: { Button("Next") {} }
    ) {}
}
