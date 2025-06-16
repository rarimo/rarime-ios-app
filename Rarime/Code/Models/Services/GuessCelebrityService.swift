import Alamofire
import Foundation

class GuessCelebrityService {
    let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func createUser(jwt: JWT, referredBy: String? = nil) async throws -> GuessCelebrityUserResponse {
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")])

        let nullifier = jwt.payload.sub
        let requestUrl = url.appendingPathComponent("integrations/guess-celebrity-svc/v1/public/users")

        let requestPayload = GuessCelebrityUserRequest(
            data: GuessCelebrityUserRequestData(
                id: nullifier,
                type: "users",
                attributes: GuessCelebrityUserRequestAttributes(
                    referredBy: referredBy
                )
            )
        )

        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GuessCelebrityUserResponse.self)
            .result
            .get()

        return response
    }

    func getUserInformation(jwt: JWT) async throws -> GuessCelebrityUserResponse {
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")])

        let nullifier = jwt.payload.sub
        let requestUrl = url.appendingPathComponent("integrations/guess-celebrity-svc/v1/public/users/\(nullifier)")

        let response = try await AF.request(requestUrl, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GuessCelebrityUserResponse.self)
            .result
            .get()

        return response
    }

    func addExtraAttempt(jwt: JWT) async throws -> Data {
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")])

        let nullifier = jwt.payload.sub
        let requestUrl = url.appendingPathComponent("integrations/guess-celebrity-svc/v1/public/users/\(nullifier)/extra")

        let response = try await AF.request(requestUrl, method: .post, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingData()
            .result
            .get()

        return response
    }

    func submitCelebrityGuess(_ jwt: JWT, _ features: [Float]) async throws -> GuessCelebritySubmitResponse {
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")])

        let nullifier = jwt.payload.sub
        let requestUrl = url.appendingPathComponent("integrations/guess-celebrity-svc/v1/public/users/\(nullifier)/guess")

        let requestPayload = GuessCelebritySubmitRequest(
            data: GuessCelebritySubmitRequestData(
                type: "feature_vector",
                attributes: GuessCelebritySubmitRequestAttributes(
                    features: features
                )
            )
        )

        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GuessCelebritySubmitResponse.self)
            .result
            .get()

        return response
    }
}

// MARK: - User request

struct GuessCelebrityUserRequest: Codable {
    let data: GuessCelebrityUserRequestData
}

struct GuessCelebrityUserRequestData: Codable {
    let id, type: String
    let attributes: GuessCelebrityUserRequestAttributes
}

struct GuessCelebrityUserRequestAttributes: Codable {
    let referredBy: String?

    enum CodingKeys: String, CodingKey {
        case referredBy = "referred_by"
    }
}

// MARK: - User response

struct GuessCelebrityUserResponse: Codable {
    let data: GuessCelebrityUserResponseData
    let included: [GuessCelebrityUserResponseIncluded]
}

struct GuessCelebrityUserResponseData: Codable {
    let id, type: String
    let attributes: GuessCelebrityUserResponseAttributes
    let relationships: GuessCelebrityUserResponseRelationships
}

struct GuessCelebrityUserResponseAttributes: Codable {
    let referralCode: String
    let referralsCount: Int
    let referralsLimit: Int
    let socialShare: Bool
    let createdAt: Int
    let updatedAt: Int

    enum CodingKeys: String, CodingKey {
        case referralCode = "referral_code"
        case referralsCount = "referrals_count"
        case referralsLimit = "referrals_limit"
        case socialShare = "social_share"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct GuessCelebrityUserResponseRelationships: Codable {
    let userStats: JsonApiRelationship
    let celebrity: JsonApiRelationship

    enum CodingKeys: String, CodingKey {
        case userStats = "user_stats"
        case celebrity
    }
}

struct GuessCelebrityUserResponseIncluded: Codable {
    let id, type: String
    let attributes: GuessCelebrityUserResponseIncludedAttributes
}

enum GuessCelebrityStatus: String, Codable {
    case active, completed, maintenance
}

struct GuessCelebrityUserResponseIncludedAttributes: Codable {
    // user_stats
    let attemptsLeft: Int?
    let extraAttemptsLeft: Int?
    let totalAttemptsCount: Int?
    let resetTime: TimeInterval?

    // celebrity
    let title: String?
    let description: String?
    let status: GuessCelebrityStatus?
    let image: String?
    let hint: String?
    let winner: String?

    enum CodingKeys: String, CodingKey {
        case attemptsLeft = "attempts_left"
        case extraAttemptsLeft = "extra_attempts_left"
        case totalAttemptsCount = "total_attempts_count"
        case resetTime = "reset_time"
        case title, description, status, image, hint, winner
    }
}

// MARK: - Submit guess request

struct GuessCelebritySubmitRequest: Codable {
    let data: GuessCelebritySubmitRequestData
}

struct GuessCelebritySubmitRequestData: Codable {
    let type: String
    let attributes: GuessCelebritySubmitRequestAttributes
}

struct GuessCelebritySubmitRequestAttributes: Codable {
    let features: [Float]
}

// MARK: - Submit guess response

struct GuessCelebritySubmitResponse: Codable {
    let data: GuessCelebritySubmitResponseData
    let included: [GuessCelebrityUserResponseIncluded]
}

struct GuessCelebritySubmitResponseData: Codable {
    let id, type: String
    let attributes: GuessCelebritySubmitResponseAttributes
    let relationships: GuessCelebrityUserResponseRelationships
}

struct GuessCelebritySubmitResponseAttributes: Codable {
    let success: Bool
    let originalFeatureVector: [Float]?

    enum CodingKeys: String, CodingKey {
        case success
        case originalFeatureVector = "original_feature_vector"
    }
}
