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

    enum CodingKeys: String, CodingKey {
        case id, title, icon, amount, date, type
    }

    init(title: String, icon: String, amount: Double, date: Date, type: TransactionType) {
        self.title = title
        self.icon = icon
        self.amount = amount
        self.date = date
        self.type = type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decode(String.self, forKey: .icon)
        amount = try container.decode(Double.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        type = try container.decode(TransactionType.self, forKey: .type)
    }
}
