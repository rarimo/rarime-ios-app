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
                        Image(.caretLeft)
                            .iconMedium()
                            .foregroundColor(.textPrimary)
                    }
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 32) {
                    Text(title)
                        .subtitle4()
                        .foregroundColor(.textPrimary)
                    content()
                }
                .padding(.vertical, 24)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            Spacer()
            HStack {
                nextButton()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.bgPure)
        }
        .background(.bgPrimary)
    }
}

#Preview {
    IdentityStepLayoutView(
        title: "New recovery phrase",
        onBack: {},
        nextButton: { Button("Next") {} }
    ) {}
}
