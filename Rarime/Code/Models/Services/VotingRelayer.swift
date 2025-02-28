import Foundation
import Alamofire

// TODO: change if needed after BE impl
class VotingRelayer {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func vote(
        _ proposalId: Int,
        _ calldata: String,
        _ destination: String
    ) async throws -> VoteResponse {
        let requestUrl = url.appendingPathComponent("/integrations/voting-relayer/v1/vote")
        
        let payload = VoteRequest(
            data: VoteRequestData(
                type: "vote",
                attributes: VoteRequestAttributes(
                    txData: calldata,
                    destination: destination,
                    proposalId: proposalId
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
    let proposalId: Int

    enum CodingKeys: String, CodingKey {
        case txData = "tx_data"
        case destination
        case proposalId = "proposal_id"
    }
}

struct VoteResponse: Codable {
    let data: VoteResponseData
}

struct VoteResponseData: Codable {
    let id, type: String
}
