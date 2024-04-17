import SwiftUI

private enum WalletRoute: Hashable {
    case send, receive
}

struct WalletView: View {
    @State private var path: [WalletRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: WalletRoute.self) { route in
                switch route {
                case .send:
                    Text("Send")
                case .receive:
                    Text("Receive")
                }
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            VStack {
                transactionsCard
                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPrimary)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Wallet")
                .subtitle2()
                .foregroundStyle(.textPrimary)
            VStack(alignment: .leading, spacing: 8) {
                Text("Available RMO")
                    .body3()
                    .foregroundStyle(.textSecondary)
                Text("3")
                    .h4()
                    .foregroundStyle(.textPrimary)
            }
            HorizontalDivider()
            HStack(spacing: 12) {
                AppButton(
                    variant: .secondary,
                    text: "Receive",
                    leftIcon: Icons.arrowDown,
                    action: { path.append(.receive) }
                )
                AppButton(
                    variant: .secondary,
                    text: "Send",
                    leftIcon: Icons.arrowUp,
                    action: { path.append(.send) }
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.backgroundPure)
    }

    private var transactionsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 20) {
                Text("Transactions")
                    .subtitle3()
                    .foregroundStyle(.textPrimary)
                HStack(spacing: 16) {
                    Image(Icons.airdrop)
                        .iconMedium()
                        .padding(10)
                        .background(.componentPrimary)
                        .foregroundStyle(.textSecondary)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Airdrop")
                            .subtitle4()
                            .foregroundStyle(.textPrimary)
                        Text("21 Dec, 2024")
                            .body4()
                            .foregroundStyle(.textSecondary)
                    }
                    Spacer()
                    Text("+3 RMO")
                        .subtitle5()
                        .foregroundStyle(.successMain)
                }
            }
        }
    }
}

#Preview {
    WalletView()
}
