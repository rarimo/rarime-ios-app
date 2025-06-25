import SwiftUI

private enum WalletRoute: String, Hashable {
    case receive, send
}

// TODO: move to model/manager
enum WalletToken: String {
    case eth = "ETH"
}

// TODO: move to model/manager
struct WalletAsset {
    let token: WalletToken
    var balance: Double
    var usdBalance: Double?
}

struct WalletView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [WalletRoute] = []
    @State private var isTransactionsLoading = false

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: WalletRoute.self) { route in
                switch route {
                case .receive:
                    WalletReceiveView(
                        address: userManager.ethereumAddress ?? "",
                        token: WalletToken.eth,
                        onBack: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .send:
                    WalletSendView(
                        token: WalletToken.eth,
                        onBack: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                }
            }
        }
        .onAppear {
            isTransactionsLoading = walletManager.transactions.isEmpty
        }
        .task { await fetchBalance() }
        .task {
            if isTransactionsLoading {
                await walletManager.loadTransactions()
                isTransactionsLoading = false
            }
        }
    }

    private var content: some View {
        MainViewLayout {
            VStack(alignment: .leading, spacing: 20) {
                header
                transactionsList
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bgPrimary)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 40) {
            Text("Wallet")
                .subtitle4()
                .foregroundStyle(.textPrimary)
            VStack(spacing: 8) {
                Text("Total Balance")
                    .body4()
                    .foregroundStyle(.textSecondary)
                HStack(alignment: .center, spacing: 8) {
                    if walletManager.isBalanceLoading {
                        ProgressView()
                    } else {
                        Button(action: {
                            Task { await fetchBalance() }
                        }) {
                            Text(walletManager.displayedBalance)
                                .h4()
                                .foregroundStyle(.textPrimary)
                        }
                    }
                    Text(WalletToken.eth.rawValue)
                        .overline2()
                        .foregroundStyle(.textPrimary)
                }
                .frame(height: 40)
                .zIndex(1)
            }
            .frame(maxWidth: .infinity)
            .zIndex(1)
            HStack(spacing: 32) {
                WalletButton(
                    text: String(localized: "Receive"),
                    icon: .arrowDown,
                    action: { path.append(.receive) }
                )
                WalletButton(
                    text: String(localized: "Send"),
                    icon: .arrowUp,
                    action: { path.append(.send) }
                )
            }
            .frame(maxWidth: .infinity)
            HorizontalDivider()
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
    }

    private var transactionsList: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text("Transactions")
                    .subtitle5()
                    .foregroundStyle(.textPrimary)
                if isTransactionsLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    RefreshableInfiniteScrollView(
                        hasMore: walletManager.hasMoreTransactions,
                        onRefresh: { await walletManager.loadTransactions() },
                        onLoadMore: { await walletManager.loadNextTransactions() }
                    ) {
                        if walletManager.transactions.isEmpty {
                            Text("No transactions yet")
                                .body4()
                                .foregroundStyle(.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(walletManager.transactions) { tx in
                                    TransactionItem(tx: tx, token: WalletToken.eth)
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    @MainActor
    func fetchBalance() async {
        do {
            try await walletManager.updateBalance()
        } catch {
            LoggerUtil.common.error("Failed to fetch balance: \(error.localizedDescription, privacy: .public)")
            AlertManager.shared.emitError("Failed to fetch balance")
        }
    }
}

private struct WalletButton: View {
    var text: String
    var icon: ImageResource
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(14)
                    .background(.bgComponentPrimary, in: Circle())
                Text(text)
                    .buttonSmall()
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

private struct TransactionItem: View {
    var tx: Transaction
    var token: WalletToken

    private var balanceModifier: String {
        tx.type == .sent ? "-" : "+"
    }

    private var txScanUrl: URL {
        EvmScanAPI.shared.getTransactionUrl(tx.hash)
    }

    var body: some View {
        Button(action: { UIApplication.shared.open(txScanUrl) }) {
            HStack(spacing: 16) {
                Image(tx.icon)
                    .iconMedium()
                    .padding(10)
                    .background(.bgComponentPrimary)
                    .foregroundStyle(.textSecondary)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(tx.title)
                        .subtitle6()
                        .foregroundStyle(.textPrimary)
                    Text(DateUtil.dateTimeFormatter.string(from: tx.date))
                        .body5()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                if tx.amount != 0 {
                    Text(verbatim: "\(balanceModifier)\(tx.amount.format()) \(token.rawValue)")
                        .subtitle7()
                        .foregroundStyle(tx.type == .sent ? .errorMain : .successMain)
                }
            }
        }
    }
}

#Preview {
    WalletView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(UserManager())
        .environmentObject(WalletManager())
}
