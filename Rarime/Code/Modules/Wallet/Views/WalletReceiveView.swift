import SwiftUI

struct WalletReceiveView: View {
    let address: String
    let token: WalletToken
    let onBack: () -> Void

    @State private var isCopied = false

    var body: some View {
        WalletRouteLayout(
            title: String(localized: "Receive \(token.rawValue)"),
            description: String(localized: "You can use the QR code or the wallet address to deposit the \(token.rawValue) token to your account"),
            onBack: onBack
        ) {
            CardContainer {
                VStack(spacing: 20) {
                    QRCodeView(code: address)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Address")
                            .subtitle4()
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 16) {
                            Text(address)
                                .body3()
                                .foregroundStyle(.textPrimary)
                                .multilineTextAlignment(.leading)
                            Image(isCopied ? Icons.check : Icons.copySimple)
                                .iconMedium()
                                .foregroundStyle(isCopied ? .successMain : .textSecondary)
                                .onTapGesture {
                                    if isCopied { return }

                                    UIPasteboard.general.string = address
                                    isCopied = true
                                    FeedbackGenerator.shared.impact(.medium)

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        isCopied = false
                                    }
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(.componentPrimary)
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            Spacer()
        }
    }
}

#Preview {
    WalletReceiveView(
        address: "0x39872a2f48fe565b1a7b8659a1358164e57d8efe",
        token: WalletToken.rmo,
        onBack: {}
    )
}
