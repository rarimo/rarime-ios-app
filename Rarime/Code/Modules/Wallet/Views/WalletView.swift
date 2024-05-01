import SwiftUI

private enum WalletRoute: String, Hashable {
    case receive, send
}

struct WalletView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    
    @State private var path: [WalletRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: WalletRoute.self) { route in
                switch route {
                case .receive:
                    WalletReceiveView(onBack: { path.removeLast() })
                case .send:
                    WalletSendView(onBack: { path.removeLast() })
                }
            }
        }
    }

    private var content: some View {
        MainViewLayout {
            VStack(alignment: .leading, spacing: 12) {
                header
                RefreshableScrollView(
                    onRefresh: { try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC) }
                ) { _ in
                    VStack {
                        transactionsCard
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundPrimary)
        }
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
                Text((userManager.balance / Double(Rarimo.rarimoTokenMantis)).formatted())
                    .h4()
                    .foregroundStyle(.textPrimary)
            }
            VStack(spacing: 20) {
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
                ForEach(walletManager.transactions) { tx in
                    TransactionItem(tx: tx)
                }
                if walletManager.transactions.isEmpty {
                    Text("No transactions yet")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
    }
}

private struct TransactionItem: View {
    var tx: Transaction

    var balanceModifier: String {
        tx.type == .sent ? "-" : "+"
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(tx.icon)
                .iconMedium()
                .padding(10)
                .background(.componentPrimary)
                .foregroundStyle(.textSecondary)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(tx.title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Text(DateUtil.richDateFormatter.string(from: tx.date))
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            Spacer()
            Text("\(balanceModifier)\(tx.amount.formatted()) RMO")
                .subtitle5()
                .foregroundStyle(tx.type == .sent ? .errorMain : .successMain)
        }
    }
}

#Preview {
    WalletView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
}
