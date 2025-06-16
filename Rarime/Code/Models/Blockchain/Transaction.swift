import Foundation
import Web3

enum TransactionType: String, Codable {
    case sent, received
}

struct Transaction: Identifiable {
    var id = UUID()
    var title: String
    var icon: ImageResource
    var amount: EthereumQuantity
    var date: Date
    var type: TransactionType
    var hash: String

    init(
        title: String,
        icon: ImageResource,
        amount: EthereumQuantity,
        date: Date,
        type: TransactionType,
        hash: String
    ) {
        self.title = title
        self.icon = icon
        self.amount = amount
        self.date = date
        self.type = type
        self.hash = hash
    }
}
