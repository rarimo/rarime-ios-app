import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published private(set) var transactions: [Transaction] {
        didSet {
            AppUserDefaults.shared.walletTransactions = try! JSONEncoder().encode(transactions)
        }
    }

    @Published var isClaimed: Bool {
        didSet {
            AppUserDefaults.shared.isAirdropClaimed = isClaimed
        }
    }

    init() {
        isClaimed = true
        transactions = AppUserDefaults.shared.walletTransactions.isEmpty
            ? []
            : try! JSONDecoder().decode([Transaction].self, from: AppUserDefaults.shared.walletTransactions)

        Task {
            do {
                let isClaimed = try await UserManager.shared.isAirdropClaimed()

                DispatchQueue.main.async { self.isClaimed = isClaimed }
            } catch {}
        }
    }

    @MainActor
    func claimAirdrop() async throws {
        if isClaimed {
            return
        }

        try await Task.sleep(nanoseconds: 1_200_000_000)
        transactions.append(
            Transaction(
                title: String(localized: "Airdrop"),
                icon: Icons.airdrop,
                amount: 3.0,
                date: Date(),
                type: .received
            )
        )
        isClaimed = true
    }

    func transfer(_ amount: Double) {
        transactions.append(
            Transaction(
                title: String(localized: "Send"),
                icon: Icons.arrowUp,
                amount: amount,
                date: Date(),
                type: .sent
            )
        )
    }

    func reset() {
        transactions = []
        isClaimed = false
    }
}
