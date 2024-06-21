import SwiftUI

private enum WalletRoute: String, Hashable {
    case receive, send
}

// TODO: move to model/manager
enum WalletToken: String {
    case rmo = "RMO"
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

    @State private var isBalanceFetching = false
    @State private var cancelables: [Task<Void, Never>] = []

    // TODO: use the token from the manager and save to store
    @State private var token = WalletToken.rmo

    @State private var selectedAsset = WalletAsset(
        token: WalletToken.rmo,
        balance: 0,
        usdBalance: nil
    )

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: WalletRoute.self) { route in
                switch route {
                case .receive:
                    WalletReceiveView(
                        address: userManager.userAddress,
                        token: token,
                        onBack: { path.removeLast() }
                    )
                case .send:
                    WalletSendView(
                        token: token,
                        onBack: { path.removeLast() }
                    )
                }
            }
        }
    }

    private var content: some View {
        MainViewLayout {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    AssetsSlider(walletAssets: [selectedAsset], isLoading: isBalanceFetching)
                    HorizontalDivider()
                        .padding(.horizontal, 20)
                    transactionsList
                }
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundPrimary)
        }
        .onAppear(perform: fetchBalance)
        .onDisappear(perform: cleanup)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 40) {
            Text("Wallet")
                .subtitle2()
                .foregroundStyle(.textPrimary)
            VStack(spacing: 8) {
                Text("Total Balance")
                    .body3()
                    .foregroundStyle(.textSecondary)
                HStack(spacing: 8) {
                    if isBalanceFetching {
                        ProgressView()
                    } else {
                        Text(RarimoUtils.formatBalance(userManager.balance))
                            .h4()
                            .foregroundStyle(.textPrimary)
                    }
                    AppDropdown(value: $token, options: [
                        DropdownOption(label: WalletToken.rmo.rawValue, value: WalletToken.rmo),
                    ])
                    .padding(.top, 8)
                }
                .frame(height: 40)
                .zIndex(1)
                Text(try! String(selectedAsset.usdBalance == nil ? "---" : "≈$\((selectedAsset.usdBalance ?? 0).formatted())"))
                    .caption2()
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .zIndex(1)
            HStack(spacing: 32) {
                WalletButton(
                    text: String(localized: "Receive"),
                    icon: Icons.arrowDown,
                    action: { path.append(.receive) }
                )
                WalletButton(
                    text: String(localized: "Send"),
                    icon: Icons.arrowUp,
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
            VStack(alignment: .leading, spacing: 20) {
                Text("Transactions")
                    .subtitle3()
                    .foregroundStyle(.textPrimary)
                ForEach(walletManager.transactions) { tx in
                    TransactionItem(tx: tx, token: token)
                }
                if walletManager.transactions.isEmpty {
                    Text("No transactions yet")
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    func fetchBalance() {
        isBalanceFetching = true

        let cancelable = Task { @MainActor in

            defer {
                self.isBalanceFetching = false
            }

            do {
                let balance = try await userManager.fetchBalanse()
                self.userManager.balance = Double(balance) ?? 0

                self.selectedAsset.balance = self.userManager.balance / Double(Rarimo.rarimoTokenMantis)
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to fetch balance: \(error.localizedDescription, privacy: .public)")
            }
        }

        cancelables.append(cancelable)
    }

    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
}

private struct WalletButton: View {
    var text: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(14)
                    .background(.componentPrimary, in: Circle())
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
            Text("\(balanceModifier)\(tx.amount.formatted()) \(token.rawValue)")
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
