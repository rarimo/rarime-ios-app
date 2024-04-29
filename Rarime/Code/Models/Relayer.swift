import Alamofire
import Foundation

class Relayer {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func register(_ calldata: Data) async throws -> EvmTxResponse {
        var requestURL = url
        requestURL.append(path: "/integrations/registration-relayer/v1/register")
        
        let payload = RegisterRequest(data: RegisterRequestData(txData: "0x" + calldata.hex))
        
        return try await AF.request(
            requestURL,
            method: .post,
            parameters: payload,
            encoder: JSONParameterEncoder.default
        )
        .serializingDecodable(EvmTxResponse.self)
        .result
        .get()
    }
    
    func airdrop(_ queryZkProof: ZkProof, to destionation: String) async throws -> AirDropResponse {
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
        
        let payloadJson = try JSONEncoder().encode(payload)
        
        return try await AF.request(
            requestURL,
            method: .post,
            parameters: payload,
            encoder: JSONParameterEncoder.default
        )
        .serializingDecodable(AirDropResponse.self)
        .result
        .get()
    }
}

struct RegisterRequest: Codable {
    let data: RegisterRequestData
}
struct RegisterRequestData: Codable {
    let txData: String

    enum CodingKeys: String, CodingKey {
        case txData = "tx_data"
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
