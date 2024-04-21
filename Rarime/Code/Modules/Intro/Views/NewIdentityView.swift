import SwiftUI

struct NewIdentityView: View {
    @EnvironmentObject private var identityManager: IdentityManager
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var isCopied = false

    var body: some View {
        IdentityStepLayoutView(
            step: 1,
            title: "Your Private Key",
            onBack: onBack,
            nextButton: {
                AppButton(
                    text: "Continue",
                    rightIcon: Icons.arrowRight,
                    action: onNext
                ).controlSize(.large)
            }
        ) {
            CardContainer {
                VStack(spacing: 20) {
                    ZStack {
                        Text(identityManager.privateKey)
                            .body3()
                            .foregroundStyle(.textPrimary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(.componentPrimary)
                    .cornerRadius(8)
                    copyButton
                    HorizontalDivider()
                    InfoAlert(text: "Please store the private key safely and do not share it with anyone. If you lose this key, you will not be able to recover the account and will lose access forever.") {}
                }
            }
        }
    }

    var copyButton: some View {
        Button(action: {
            if isCopied { return }

            UIPasteboard.general.string = identityManager.privateKey
            isCopied = true
            FeedbackGenerator.shared.impact(.medium)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCopied = false
            }
        }) {
            HStack {
                Image(isCopied ? Icons.check : Icons.copySimple).iconMedium()
                Text(isCopied ? "Copied" : "Copy to clipboard").buttonMedium()
            }
            .foregroundStyle(.textPrimary)
        }
    }
}

#Preview {
    NewIdentityView(onBack: {}, onNext: {})
        .environmentObject(IdentityManager())
}
