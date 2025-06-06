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
                        address: userManager.ethereumAddress ?? "",
                        token: token,
                        onBack: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                case .send:
                    WalletSendView(
                        token: token,
                        onBack: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
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
            .background(.bgPrimary)
        }
        .onAppear(perform: fetchBalance)
        .onDisappear(perform: cleanup)
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
                    if isBalanceFetching {
                        ProgressView()
                    } else {
                        Text(RarimoUtils.formatBalance(userManager.balance))
                            .h4()
                            .foregroundStyle(.textPrimary)
                    }
                    Text(WalletToken.rmo.rawValue)
                        .overline2()
                        .foregroundStyle(.textPrimary)
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
                    .subtitle5()
                    .foregroundStyle(.textPrimary)
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

    var balanceModifier: String {
        tx.type == .sent ? "-" : "+"
    }

    var body: some View {
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
                Text(DateUtil.richDateFormatter.string(from: tx.date))
                    .body5()
                    .foregroundStyle(.textSecondary)
            }
            Spacer()
            Text("\(balanceModifier)\(tx.amount.formatted()) \(token.rawValue)")
                .subtitle7()
                .foregroundStyle(tx.type == .sent ? .errorMain : .successMain)
        }
    }
}

#Preview {
    WalletView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(UserManager())
}
