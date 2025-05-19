import Alamofire
import Foundation

class Relayer {
    let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func register(
        _ calldata: Data,
        _ destination: String? = nil,
        _ noSend: Bool = false,
        meta: [String: String]? = nil
    ) async throws -> EvmTxResponse {
        var requestURL = url
        requestURL.append(path: "/integrations/registration-relayer/v1/register")

        let payload = RegisterRequest(
            data: RegisterRequestData(
                txData: "0x" + calldata.hex,
                destination: destination,
                noSend: noSend,
                meta: meta
            )
        )

        return try await AF.request(
            requestURL,
            method: .post,
            parameters: payload,
            encoder: JSONParameterEncoder.default
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(EvmTxResponse.self)
        .result
        .get()
    }
}

struct RegisterRequest: Encodable {
    let data: RegisterRequestData
}

struct RegisterRequestData: Encodable {
    let txData: String
    let destination: String?
    let noSend: Bool?
    let meta: [String: String]?

    enum CodingKeys: String, CodingKey {
        case txData = "tx_data"
        case destination
        case noSend = "no_send"
    }
}
