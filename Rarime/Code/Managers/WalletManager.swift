import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published private(set) var balance: Double {
        didSet {
            AppUserDefaults.shared.walletBalance = balance
        }
    }

    @Published private(set) var transactions: [Transaction]

    @Published private(set) var isClaimed: Bool {
        didSet {
            AppUserDefaults.shared.isAirdropClaimed = isClaimed
        }
    }

    init() {
        balance = AppUserDefaults.shared.walletBalance
        isClaimed = AppUserDefaults.shared.isAirdropClaimed
        transactions = AppUserDefaults.shared.walletTransactions.isEmpty
            ? []
            : try! JSONDecoder().decode([Transaction].self, from: AppUserDefaults.shared.walletTransactions)
    }

    var address: String {
        // TODO: Get the address from the user's wallet
        "rarimo10xf20zsda2hpjstl3l5ahf65tzkkdnhaxlsl8a"
    }

    @MainActor
    func claimAirdrop() async throws {
        if isClaimed {
            return
        }

        try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
        balance += 3.0
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
