import SwiftUI

struct WalletReceiveView: View {
    @EnvironmentObject private var walletManager: WalletManager
    let onBack: () -> Void

    @State private var isCopied = false

    var body: some View {
        WalletRouteLayout(
            title: String(localized: "Receive RMO"),
            description: String(localized: "You can use the QR code or the wallet address to deposit the RMO token to your account"),
            onBack: onBack
        ) {
            CardContainer {
                VStack(spacing: 20) {
                    QRCodeView(code: walletManager.address)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Rarimo Adress")
                            .subtitle4()
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 16) {
                            Text(walletManager.address)
                                .body3()
                                .foregroundStyle(.textPrimary)
                                .multilineTextAlignment(.leading)
                            Image(isCopied ? Icons.check : Icons.copySimple)
                                .iconMedium()
                                .foregroundStyle(isCopied ? .successMain : .textSecondary)
                                .onTapGesture {
                                    if isCopied { return }

                                    UIPasteboard.general.string = walletManager.address
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
    WalletReceiveView(onBack: {})
        .environmentObject(WalletManager())
}
