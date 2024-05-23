import Foundation

struct AirdropResponse: Codable {
    let data: AirdropResponseData
}

struct AirdropResponseData: Codable {
    let id, type: String
    let attributes: AirdropResponseAttributes
}

struct AirdropResponseAttributes: Codable {
    let address, amount, createdAt, nullifier: String
    let status, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case address, amount
        case createdAt = "created_at"
        case nullifier, status
        case updatedAt = "updated_at"
    }
}
