import Foundation

import Alamofire

class EvmScanAPI {
    static let shared = EvmScanAPI()

    let scanUrl: URL
    let apiUrl: URL

    init() {
        self.scanUrl = ConfigManager.shared.evm.scanUrl
        self.apiUrl = ConfigManager.shared.evm.scanApiUrl
    }

    func getTransactions(_ address: String, _ nextPageParams: EvmScanTransactionNextPageParams? = nil) async throws -> EvmScanTransaction {
        var requestUrl = apiUrl.appendingPathComponent("api/v2/addresses/\(address)/transactions")

        if let nextPageParams {
            requestUrl.append(queryItems: nextPageParams.toHTTPQueryParams())
        }

        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(EvmScanTransaction.self)
            .result
            .get()

        return response
    }

    func getTransactionUrl(_ hash: String) -> URL {
        return scanUrl.appendingPathComponent("tx/\(hash)")
    }
}
