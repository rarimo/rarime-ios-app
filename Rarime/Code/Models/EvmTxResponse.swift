import Foundation

struct EvmTxResponse: Codable {
    let data: EvmTxResponseData
    let included: [String]
}

struct EvmTxResponseData: Codable {
    let id, type: String
    let attributes: EvmTxResponseAttributes
}

struct EvmTxResponseAttributes: Codable {
    let txHash: String

    enum CodingKeys: String, CodingKey {
        case txHash = "tx_hash"
    }
}
