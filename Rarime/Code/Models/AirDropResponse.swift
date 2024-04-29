import Foundation

struct AirDropResponse: Codable {
    let data: AirDropResponseData
    let included: [String]
}

struct AirDropResponseData: Codable {
    let id, type: String
    let attributes: AirDropResponseAttributes
}

struct AirDropResponseAttributes: Codable {
    let address, amount, createdAt, status: String
    let txHash, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case address, amount
        case createdAt = "created_at"
        case status
        case txHash = "tx_hash"
        case updatedAt = "updated_at"
    }
}
