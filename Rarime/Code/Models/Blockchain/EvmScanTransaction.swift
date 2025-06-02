import Foundation

// MARK: - EvmScanTransaction

struct EvmScanTransaction: Codable {
    let items: [EvmScanTransactionItem]
    let nextPageParams: EvmScanTransactionNextPageParams

    enum CodingKeys: String, CodingKey {
        case items
        case nextPageParams = "next_page_params"
    }
}

// MARK: - EvmScanTransactionItem

struct EvmScanTransactionItem: Codable {
    let hash: String
    let value: String
    let from: EvmScanTransactionAddress
    let to: EvmScanTransactionAddress
    let method: String
}

// MARK: - EvmScanTransactionFrom

struct EvmScanTransactionAddress: Codable {
    let hash: String
}

// MARK: - EvmScanTransactionNextPageParams

struct EvmScanTransactionNextPageParams: Codable {
    let blockNumber: Int
    let fee, hash: String
    let index: Int
    let insertedAt: String
    let itemsCount: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case blockNumber = "block_number"
        case fee, hash, index
        case insertedAt = "inserted_at"
        case itemsCount = "items_count"
        case value
    }

    func toHTTPQueryParams() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "block_number", value: String(blockNumber)),
            URLQueryItem(name: "fee", value: fee),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "index", value: String(index)),
            URLQueryItem(name: "inserted_at", value: insertedAt),
            URLQueryItem(name: "items_count", value: String(itemsCount)),
            URLQueryItem(name: "value", value: value)
        ]
    }
}
