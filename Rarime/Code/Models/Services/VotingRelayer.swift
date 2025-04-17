import Foundation
import Alamofire

class VotingRelayer {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func vote(
        _ calldata: String,
        _ destination: String
    ) async throws -> VoteResponse {
        let requestUrl = url.appendingPathComponent("/integrations/proof-verification-relayer/v2/vote")
        
        let payload = VoteRequest(
            data: VoteRequestData(
                type: "send_transaction",
                attributes: VoteRequestAttributes(
                    txData: calldata,
                    destination: destination
                )
            )
        )
        
        return try await AF.request(
            requestUrl,
            method: .post,
            parameters: payload,
            encoder: JSONParameterEncoder.default
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(VoteResponse.self)
        .result
        .get()
    }
}

struct VoteRequest: Codable {
    let data: VoteRequestData
}

struct VoteRequestData: Codable {
    let type: String
    let attributes: VoteRequestAttributes
}

struct VoteRequestAttributes: Codable {
    let txData, destination: String

    enum CodingKeys: String, CodingKey {
        case txData = "tx_data"
        case destination
    }
}

struct VoteResponse: Codable {
    let data: VoteResponseData
}

struct VoteResponseData: Codable {
    let id, type: String
}
