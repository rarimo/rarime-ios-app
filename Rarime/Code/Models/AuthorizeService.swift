import Alamofire
import Foundation

class AuthorizeService {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func requestChallenge(_ nullifier: String) async throws -> GetChallengeResponse {
        let requestUrl = url.appendingPathComponent("integrations/decentralized-auth-svc/v1/authorize/\(nullifier)/challenge")

        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetChallengeResponse.self)
            .result
            .get()
        
        return response
    }
    
    func authorizeUser(_ nullifier: String, _ proof: ZkProof) async throws -> AuthorizeUserResponse {
        let requestUrl = url.appendingPathComponent("integrations/decentralized-auth-svc/v1/authorize")
        
        let requestPayload = AuthorizeUserRequest(
            data: AuthorizeUserRequestData(
                id: nullifier,
                type: "authorize",
                attributes: AuthorizeUserRequestAttributes(
                    proof: proof
                )
            )
        )
        
        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(AuthorizeUserResponse.self)
            .result
            .get()
        
        return response
    }
    
    func validateJwt(_ jwt: String) async throws -> ValidateJWTResponse {
        let requestUrl = url.appendingPathComponent("integrations/decentralized-auth-svc/v1/validate")
        
        let headers = [
            HTTPHeader(name: "Authorization", value: "Bearer \(jwt)")
        ]
        
        let response = try await AF.request(requestUrl, headers: HTTPHeaders(headers))
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(ValidateJWTResponse.self)
            .result
            .get()
        
        return response
    }
    
    func refreshJwt(_ jwt: String) async throws -> AuthorizeUserResponse {
        let requestUrl = url.appendingPathComponent("integrations/decentralized-auth-svc/v1/refresh")
        
        let headers = [
            HTTPHeader(name: "Authorization", value: "Bearer \(jwt)")
        ]
        
        let response = try await AF.request(requestUrl, headers: HTTPHeaders(headers))
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(AuthorizeUserResponse.self)
            .result
            .get()
        
        return response
    }
}

struct GetChallengeResponse: Codable {
    let data: GetChallengeResponseData
}

struct GetChallengeResponseData: Codable {
    let id, type: String
    let attributes: GetChallengeResponseAttributes
}

struct GetChallengeResponseAttributes: Codable {
    let challenge: Data
}

struct AuthorizeUserRequest: Codable {
    let data: AuthorizeUserRequestData
}

struct AuthorizeUserRequestData: Codable {
    let id, type: String
    let attributes: AuthorizeUserRequestAttributes
}

struct AuthorizeUserRequestAttributes: Codable {
    let proof: ZkProof
}

struct AuthorizeUserResponse: Codable {
    let data: AuthorizeUserResponseData
}

struct AuthorizeUserResponseData: Codable {
    let id, type: String
    let attributes: AuthorizeUserResponseAttributes
}

struct AuthorizeUserResponseAttributes: Codable {
    let accessToken, refreshToken: AuthorizeUserResponseToken

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct AuthorizeUserResponseToken: Codable {
    let token, tokenType: String

    enum CodingKeys: String, CodingKey {
        case token
        case tokenType = "token_type"
    }
}

struct ValidateJWTResponse: Codable {
    let data: [ValidateJWTResponseDatum]
}

struct ValidateJWTResponseDatum: Codable {
    let id, type: String
    let attributes: ValidateJWTResponseAttributes
}

struct ValidateJWTResponseAttributes: Codable {
    let claims: [ValidateJWTResponseClaim]
}

struct ValidateJWTResponseClaim: Codable {
    let nullifier: String
}
