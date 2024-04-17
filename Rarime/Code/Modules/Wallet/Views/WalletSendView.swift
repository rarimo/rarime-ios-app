import SwiftUI

struct WalletSendView: View {
    let onBack: () -> Void

    var body: some View {
        WalletRouteLayout(
            title: "Send RMO",
            description: "Withdraw the RMO token",
            onBack: onBack
        ) {
            VStack {
                CardContainer {
                    Text(String("Wallet send content"))
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}

#Preview {
    WalletSendView(onBack: {})
}
