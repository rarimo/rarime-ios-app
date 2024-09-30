import Alamofire
import Foundation

class VerificatorApi {
    static func getExternalRequestParams(url: URL) async throws -> GetProofParamsResponse {
        let response = try await AF.request(url)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetProofParamsResponse.self)
            .result
            .get()

        return response
    }

    static func sendProof(url: URL, userId: String, proof: ZkProof) async throws -> SendProofResponse {
        let request = SendProofRequest(
            data: SendProofRequestData(
                id: userId,
                type: "receive_proof",
                attributes: SendProofRequestAttributes(proof: proof)
            )
        )

        let response = try await AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(SendProofResponse.self)
            .result
            .get()

        return response
    }
    
    static func sendSignature(url: URL, userId: String, signature: String, pubSignals: PubSignals) async throws -> SendSignatureResponse {
        let request = SendSignatureRequest(
            data: SendSignatureRequestData(
                id: userId,
                type: "receive_signature",
                attributes: SendSignatureRequestAttributes(
                    signature: signature,
                    pubSignals: pubSignals
                )
            )
        )

        let response = try await AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(SendSignatureResponse.self)
            .result
            .get()

        return response
    }
}

// get proof params
struct GetProofParamsResponse: Codable {
    let data: GetProofParamsResponseData
}

struct GetProofParamsResponseData: Codable {
    let id, type: String
    let attributes: GetProofParamsResponseAttributes
}

struct GetProofParamsResponseAttributes: Codable {
    let eventID, eventData, selector: String
    let identityCounter: UInt64
    let timestampLowerBound, timestampUpperBound: String
    let identityCounterLowerBound, identityCounterUpperBound: UInt64
    let expirationDateLowerBound, expirationDateUpperBound, birthDateLowerBound, birthDateUpperBound: String
    let citizenshipMask: String
    let callbackURL: String

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case eventData = "event_data"
        case selector
        case identityCounter = "identity_counter"
        case timestampLowerBound = "timestamp_lower_bound"
        case timestampUpperBound = "timestamp_upper_bound"
        case identityCounterLowerBound = "identity_counter_lower_bound"
        case identityCounterUpperBound = "identity_counter_upper_bound"
        case expirationDateLowerBound = "expiration_date_lower_bound"
        case expirationDateUpperBound = "expiration_date_upper_bound"
        case birthDateLowerBound = "birth_date_lower_bound"
        case birthDateUpperBound = "birth_date_upper_bound"
        case citizenshipMask = "citizenship_mask"
        case callbackURL = "callback_url"
    }
}

// send proof request
struct SendProofRequest: Codable {
    let data: SendProofRequestData
}

struct SendProofRequestData: Codable {
    let id, type: String
    let attributes: SendProofRequestAttributes
}

struct SendProofRequestAttributes: Codable {
    let proof: ZkProof
}

// send data signature
struct SendSignatureRequest: Codable {
    let data: SendSignatureRequestData
}

struct SendSignatureRequestData: Codable {
    let id, type: String
    let attributes: SendSignatureRequestAttributes
}

struct SendSignatureRequestAttributes: Codable {
    let signature: String
    let pubSignals: [String]
    
    enum CodingKeys: String, CodingKey {
        case signature
        case pubSignals = "pub_signals"
    }
}

// send proof response
enum ReceivedUserStatus: String, Codable {
    case notVerified = "not_verified"
    case verified
    case failedVerification = "failed_verification"
    case uniquenessCheckFailed = "uniqueness_check_failed"
}

struct SendProofResponse: Codable {
    let data: SendProofResponseData
}

struct SendProofResponseData: Codable {
    let id, type: String
    let attributes: SendProofResponseAttributes
}

struct SendProofResponseAttributes: Codable {
    let status: ReceivedUserStatus
}

// send signature response
struct SendSignatureResponse: Codable {
    let data: SendSignatureResponseData
}

struct SendSignatureResponseData: Codable {
    let id, type: String
    let attributes: SendSignatureResponseAttributes
}

struct SendSignatureResponseAttributes: Codable {
    let status: ReceivedUserStatus
}
