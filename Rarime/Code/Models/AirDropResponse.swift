import Foundation

struct AirdropResponse: Codable {
    let data: AirdropResponseData
    let included: [String]
}

struct AirdropResponseData: Codable {
    let id, type: String
    let attributes: AirdropResponseAttributes
}

struct AirdropResponseAttributes: Codable {
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
