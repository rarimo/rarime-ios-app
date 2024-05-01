import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published private(set) var transactions: [Transaction]

    @Published private(set) var isClaimed: Bool {
        didSet {
            AppUserDefaults.shared.isAirdropClaimed = isClaimed
        }
    }

    init() {
        isClaimed = AppUserDefaults.shared.isAirdropClaimed
        transactions = AppUserDefaults.shared.walletTransactions.isEmpty
            ? []
            : try! JSONDecoder().decode([Transaction].self, from: AppUserDefaults.shared.walletTransactions)
    }

    @MainActor
    func claimAirdrop() async throws {
        if isClaimed {
            return
        }

        try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
        transactions.append(
            Transaction(
                title: String(localized: "Airdrop"),
                icon: Icons.airdrop,
                amount: 3.0,
                date: Date(),
                type: .received
            )
        )
        AppUserDefaults.shared.walletTransactions = try! JSONEncoder().encode(transactions)
        isClaimed = true
    }
}
