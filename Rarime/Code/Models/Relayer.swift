import Alamofire
import Foundation

class Relayer {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func register(_ calldata: Data, _ destination: String? = nil) async throws -> EvmTxResponse {
        var requestURL = url
        requestURL.append(path: "/integrations/registration-relayer/v1/register")
        
        let payload = RegisterRequest(
            data: RegisterRequestData(
                txData: "0x" + calldata.hex,
                destination: destination
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
    
    func airdrop(_ queryZkProof: ZkProof, to destionation: String) async throws -> AirdropResponse {
        var requestURL = url
        requestURL.append(path: "/integrations/airdrop-svc/airdrops")
        
        let payload = AirdropRequest(
            data: AirdropRequestData(
                type: "create_airdrop",
                attributes: AirdropRequestAttributes(
                    address: destionation,
                    algorithm: "SHA256withRSA",
                    zkProof: queryZkProof
                )
            )
        )
        
        return try await AF.request(
            requestURL,
            method: .post,
            parameters: payload,
            encoder: JSONParameterEncoder.default
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(AirdropResponse.self)
        .result
        .get()
    }
    
    func getAirdropInfo(_ nullifier: String) async throws -> GetAirdropResponse {
        var requestURL = url
        requestURL.append(path: "/integrations/airdrop-svc/airdrops/\(nullifier)")
        
        return try await AF.request(requestURL)
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(GetAirdropResponse.self)
        .result
        .get()
    }
    
    func getAirdropParams() async throws -> GetAirdropParamsResponse {
        var requestURL = url
        requestURL.append(path: "/integrations/airdrop-svc/airdrops/params")
        
        return try await AF.request(requestURL)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetAirdropParamsResponse.self)
            .result
            .get()
    }
}

struct RegisterRequest: JSONCodable {
    let data: RegisterRequestData
}
struct RegisterRequestData: Codable {
    let txData: String
    let destination: String?

    enum CodingKeys: String, CodingKey {
        case txData = "tx_data"
        case destination
    }
}

struct AirdropRequest: Codable {
    let data: AirdropRequestData
}
struct AirdropRequestData: Codable {
    let type: String
    let attributes: AirdropRequestAttributes
}

struct AirdropRequestAttributes: Codable {
    let address, algorithm: String
    let zkProof: ZkProof

    enum CodingKeys: String, CodingKey {
        case address, algorithm
        case zkProof = "zk_proof"
    }
}

struct GetAirdropResponse: Codable {
    let data: GetAirdropResponseData
}

struct GetAirdropResponseData: Codable {
    let id, type: String
    let attributes: GetAirdropResponseAttributes
}

struct GetAirdropResponseAttributes: Codable {
    let address, nullifier, status: String
    let createdAt, updatedAt: Date
    let amount: String

    enum CodingKeys: String, CodingKey {
        case address, nullifier, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case amount
    }
}

struct GetAirdropParamsResponse: Codable {
    let data: GetAirdropParamsResponseData
}

struct GetAirdropParamsResponseData: Codable {
    let id, type: String
    let attributes: GetAirdropParamsResponseAttributes
}

struct GetAirdropParamsResponseAttributes: Codable {
    let eventID: String
    let querySelector: String
    let startedAt: Int

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case querySelector = "query_selector"
        case startedAt = "started_at"
    }
}

