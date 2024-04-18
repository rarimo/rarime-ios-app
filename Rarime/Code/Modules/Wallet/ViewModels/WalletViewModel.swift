import Foundation

enum TransactionType: String {
    case sent, received
}

struct Transaction: Identifiable {
    var id = UUID()
    var title: String
    var icon: String
    var amount: Double
    var date: Date
    var type: TransactionType
}

class WalletViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var transactions: [Transaction] = []
    @Published var isClaimed: Bool = false

    var address: String {
        // TODO: Get the address from the user's wallet
        "rarimo10xf20zsda2hpjstl3l5ahf65tzkkdnhaxlsl8a"
    }

    @MainActor
    func claimAirdrop() async {
        if isClaimed {
            return
        }

        // TODO: Claim RMO token
        do {
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
            isClaimed = true
        } catch {
            print(error.localizedDescription)
        }
    }
}
