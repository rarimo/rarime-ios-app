import Foundation

enum TransactionType: String, Codable {
    case sent, received
}

struct Transaction: Identifiable {
    var id = UUID()
    var title: String
    var icon: ImageResource
    var amount: Double
    var date: Date
    var type: TransactionType

    init(title: String, icon: ImageResource, amount: Double, date: Date, type: TransactionType) {
        self.title = title
        self.icon = icon
        self.amount = amount
        self.date = date
        self.type = type
    }
}
