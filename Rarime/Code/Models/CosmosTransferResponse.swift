import Foundation

struct CosmosTransferResponse: Codable {
    let data: CosmosTransferData
}

struct CosmosTransferData: Codable {
    let id, type: String
    let attributes: CosmosTransferAttributes
}

struct CosmosTransferAttributes: Codable {
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
