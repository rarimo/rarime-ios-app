import Foundation

enum TransactionType: String, Codable {
    case sent, received
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var title: String
    var icon: String
    var amount: Double
    var date: Date
    var type: TransactionType

    init(title: String, icon: String, amount: Double, date: Date, type: TransactionType) {
        self.title = title
        self.icon = icon
        self.amount = amount
        self.date = date
        self.type = type
    }
}
