import Foundation

import Alamofire

class EvmScanAPI {
    static let shared = EvmScanAPI()

    let url: URL

    init() {
        self.url = ConfigManager.shared.api.evmScanApiUrl
    }

    func getTransactions(_ address: String, _ nextPageParams: EvmScanTransactionNextPageParams? = nil) async throws -> EvmScanTransaction {
        var requestUrl = url.appendingPathComponent("api/v2/addresses/\(address)/transactions")

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
}
