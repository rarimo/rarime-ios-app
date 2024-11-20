import Alamofire
import Foundation

class Points {
    static let PointsEventId = "0x77fabbc6cb41a11d4fb6918696b3550d5d602f252436dd587f9065b7c4e62b"

    let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func createPointsBalance(_ jwt: JWT, _ refaralCode: String) async throws -> CreatePointBalanceResponse {
        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances")

        let requestPayload = CreatePointBalanceRequest(
            data: CreatePointBalanceRequestData(
                id: jwt.payload.sub,
                type: "create_balance",
                attributes: CreatePointBalanceRequestAttributes(
                    referredBy: refaralCode
                )
            )
        )

        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(CreatePointBalanceResponse.self)
            .result
            .get()

        return response
    }

    func getLeaderboard(_ pageLimit: Int, _ pageNumber: Int, _ pageOrder: String = "desc") async throws -> GetLeaderboardResponse {
        let query = [
            URLQueryItem(name: "page[limit]", value: String(pageLimit)),
            URLQueryItem(name: "page[number]", value: String(pageNumber)),
            URLQueryItem(name: "page[order]", value: pageOrder),
            URLQueryItem(name: "count", value: "true")
        ]

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances").appending(queryItems: query)

        var response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetLeaderboardResponse.self)
            .result
            .get()

        // FIXME: make it better
        for (index, entry) in response.data.enumerated() {
            response.data[index].attributes.id = entry.id
        }

        return response
    }

    func getPointsBalance(_ jwt: JWT, _ rank: Bool? = nil, _ referral_codes: Bool? = nil) async throws -> GetPointsBalanceResponse {
        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )

        let nullifier = jwt.payload.sub

        var query = [URLQueryItem]()

        if let rank = rank {
            query.append(URLQueryItem(name: "rank", value: String(rank)))
        }

        if let referral_codes = referral_codes {
            query.append(URLQueryItem(name: "referral_codes", value: String(referral_codes)))
        }

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifier)").appending(queryItems: query)

        var response = try await AF.request(requestUrl, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetPointsBalanceResponse.self)
            .result
            .get()

        // FIXME: make it better
        response.data.attributes.id = response.data.id

        return response
    }

    func activatePointsBalance(_ jwt: JWT, _ refaralCode: String) async throws -> CreatePointBalanceRequest {
        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(jwt.payload.sub)")

        let requestPayload = CreatePointBalanceRequest(
            data: CreatePointBalanceRequestData(
                id: jwt.payload.sub,
                type: "update_balance",
                attributes: CreatePointBalanceRequestAttributes(
                    referredBy: refaralCode
                )
            )
        )

        let response = try await AF.request(requestUrl, method: .patch, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(CreatePointBalanceRequest.self)
            .result
            .get()

        return response
    }

    func verifyPassport(
        _ jwt: JWT,
        _ zkProof: ZkProof,
        _ signature: String,
        _ country: String,
        _ anonymousId: String
    ) async throws -> VerifyPassportResponse {
        let nullifier = jwt.payload.sub

        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Signature", value: signature),
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifier)/verifypassport")

        let requestPayload = VerifyPassportRequest(
            data: VerifyPassportRequestData(
                id: nullifier,
                type: "verify_passport",
                attributes: VerifyPassportRequestAttributes(
                    anonymousId: anonymousId,
                    country: country,
                    proof: zkProof
                )
            )
        )

        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(VerifyPassportResponse.self)
            .result
            .get()

        return response
    }

    func withdrawalHistory(_ nullifier: String, _ pageLimit: Int, _ pageNumber: Int, _ pageOrder: String = "desc") async throws -> WithdrawalHistoryResponse {
        let query = [
            URLQueryItem(name: "page[limit]", value: String(pageLimit)),
            URLQueryItem(name: "page[number]", value: String(pageNumber)),
            URLQueryItem(name: "page[order]", value: pageOrder)
        ]

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifier)/withdrawals").appending(queryItems: query)

        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(WithdrawalHistoryResponse.self)
            .result
            .get()

        return response
    }

    func withdrawPoints(_ nullifer: String, _ amount: Int, _ address: String, _ proof: ZkProof) async throws -> WithdrawPointsResponse {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifer)/withdrawals")

        let requestPayload = WithdrawPointsRequest(
            data: WithdrawPointsRequestData(
                id: nullifer,
                type: "withdraw",
                attributes: WithdrawPointsRequestAttributes(
                    amount: amount,
                    address: address,
                    proof: proof
                )
            )
        )

        let response = try await AF.request(requestUrl, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(WithdrawPointsResponse.self)
            .result
            .get()

        return response
    }

    func listEvents(
        _ jwt: JWT,
        filterStatus: [String]? = nil,
        filterMetaStaticName: [String]? = nil,
        count: Bool? = nil,
        pageLimit: Int? = nil,
        pageNumber: Int? = nil,
        pageOrder: String? = nil
    ) async throws -> GetEventsResponse {
        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )

        var query = [
            URLQueryItem(name: "filter[nullifier]", value: jwt.payload.sub)
        ]

        if let filterStatus = filterStatus {
            let queryValue = filterStatus.joined(separator: ",")
            query.append(URLQueryItem(name: "filter[status]", value: queryValue))
        }

        if let filterMetaStaticName = filterMetaStaticName {
            let queryValue = filterMetaStaticName
                .joined(separator: ",")
            query.append(URLQueryItem(name: "filter[meta.static.name]", value: queryValue))
        }

        if let count = count {
            query.append(URLQueryItem(name: "count", value: String(count)))
        }

        if let pageLimit = pageLimit {
            query.append(URLQueryItem(name: "page[limit]", value: String(pageLimit)))
        }

        if let pageNumber = pageNumber {
            query.append(URLQueryItem(name: "page[number]", value: String(pageNumber)))
        }

        if let pageOrder = pageOrder {
            query.append(URLQueryItem(name: "page[order]", value: pageOrder))
        }

        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/events").appending(queryItems: query)

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601

        let response = try await AF.request(requestUrl, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetEventsResponse.self, decoder: jsonDecoder)
            .result
            .get()

        return response
    }

    func getEvent(_ eventId: String) async throws -> GetEventResponse {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/events/\(eventId)")

        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetEventResponse.self)
            .result
            .get()

        return response
    }

    func claimPointsForEvent(_ eventId: String) async throws -> Data {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/events/\(eventId)")

        let requestPayload = ClaimPointsForEventRequest(
            data: ClaimPointsForEventRequestData(
                id: eventId,
                type: "claim_event"
            )
        )

        let response = try await AF.request(requestUrl, method: .patch, parameters: requestPayload, encoder: JSONParameterEncoder.default)
            .validate(OpenApiError.catchInstance)
            .serializingData()
            .result
            .get()

        return response
    }

    func joinRewardsProgram(_ jwt: JWT, _ country: String, _ signature: String, _ anonymousId: String) async throws -> VerifyPassportResponse {
        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Signature", value: signature),
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )

        let requestURL = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(jwt.payload.sub)/join_program")

        let requestPayload = JoinRewardsProgramRequest(
            data: JoinRewardsProgramRequestData(
                id: jwt.payload.sub,
                type: "verify_passport",
                attributes: JoinRewardsProgramRequestAttributes(
                    anonymousId: anonymousId,
                    country: country
                )
            )
        )

        let response = try await AF.request(requestURL, method: .post, parameters: requestPayload, encoder: JSONParameterEncoder.default, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(VerifyPassportResponse.self)
            .result
            .get()

        return response
    }
}

struct CreatePointBalanceRequest: Codable {
    let data: CreatePointBalanceRequestData
}

struct CreatePointBalanceRequestData: Codable {
    let id, type: String
    let attributes: CreatePointBalanceRequestAttributes
}

struct CreatePointBalanceRequestAttributes: Codable {
    let referredBy: String

    enum CodingKeys: String, CodingKey {
        case referredBy = "referred_by"
    }
}

struct WithdrawPointsRequest: Codable {
    let data: WithdrawPointsRequestData
}

struct WithdrawPointsRequestData: Codable {
    let id, type: String
    let attributes: WithdrawPointsRequestAttributes
}

struct WithdrawPointsRequestAttributes: Codable {
    let amount: Int
    let address: String
    let proof: ZkProof
}

struct CreatePointBalanceResponse: Codable {
    let data: CreatePointBalanceResponseData
}

struct CreatePointBalanceResponseData: Codable {
    let id, type: String
    let attributes: CreatePointBalanceResponseAttributes
}

struct CreatePointBalanceResponseAttributes: Codable {
    let amount: Int
    let isDisabled: Bool
    let createdAt, updatedAt, rank: Int
    let level: Int

    enum CodingKeys: String, CodingKey {
        case amount
        case isDisabled = "is_disabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rank
        case level
    }
}

struct GetLeaderboardResponse: Codable {
    var data: [GetLeaderboardResponseData]
    var meta: GetLeaderboardResponseMeta
}

struct GetLeaderboardResponseData: Codable {
    let id, type: String
    var attributes: LeaderboardEntry
}

struct GetLeaderboardResponseMeta: Codable {
    let eventsCount: Int

    enum CodingKeys: String, CodingKey {
        case eventsCount = "events_count"
    }
}

struct LeaderboardEntry: Codable {
    var id: String?
    let amount: Int
    let createdAt, updatedAt, rank: Int
    let level: Int

    enum CodingKeys: String, CodingKey {
        case amount
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rank
        case level
    }
}

struct GetPointsBalanceResponse: Codable {
    var data: GetPointsBalanceResponseData
}

struct GetPointsBalanceResponseData: Codable {
    let id, type: String
    var attributes: PointsBalanceRaw
}

struct PointsBalanceRaw: Codable {
    var id: String?
    let amount: Int
    let isDisabled: Bool
    let createdAt, updatedAt: Int
    let rank: Int?
    let referralCodes: [ReferalCode]?
    let level: Int
    let isVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case isDisabled = "is_disabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rank
        case referralCodes = "referral_codes"
        case level
        case isVerified = "is_verified"
    }

    func toLeaderboardEntry() -> LeaderboardEntry {
        return LeaderboardEntry(
            id: id,
            amount: amount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rank: rank ?? 0,
            level: level
        )
    }
}

struct ReferalCode: Codable {
    let id: String
    let status: ReferralCodeStatus
}

enum ReferralCodeStatus: String, Codable {
    case active
    case banned
    case limited
    case awaiting
    case rewarded
    case consumed
}

struct VerifyPassportRequest: Codable {
    let data: VerifyPassportRequestData
}

struct VerifyPassportRequestData: Codable {
    let id, type: String
    let attributes: VerifyPassportRequestAttributes
}

struct VerifyPassportRequestAttributes: Codable {
    let anonymousId: String
    let country: String
    let proof: ZkProof

    enum CodingKeys: String, CodingKey {
        case anonymousId = "anonymous_id"
        case country, proof
    }
}

struct WithdrawalHistoryResponse: Codable {
    let data: [WithdrawalHistoryResponseData]
}

struct WithdrawalHistoryResponseData: Codable {
    let id, type: String
    let attributes: WithdrawalHistoryResponseAttributes
    let relationships: WithdrawalHistoryResponseRelationships
}

struct WithdrawalHistoryResponseAttributes: Codable {
    let amount: Int
    let address: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case amount, address
        case createdAt = "created_at"
    }
}

struct WithdrawalHistoryResponseRelationships: Codable {
    let balance: WithdrawalHistoryResponseBalance
}

struct WithdrawalHistoryResponseBalance: Codable {
    let data: WithdrawalHistoryResponseBalanceData
}

struct WithdrawalHistoryResponseBalanceData: Codable {
    let id, type: String
}

struct WithdrawPointsResponse: Codable {
    let data: WithdrawPointsResponseData
    let included: [WithdrawPointsResponseIncluded]
}

struct WithdrawPointsResponseData: Codable {
    let id, type: String
    let attributes: WithdrawPointsResponseDataAttributes
    let relationships: WithdrawPointsResponseRelationships
}

struct WithdrawPointsResponseDataAttributes: Codable {
    let amount: Int
    let address: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case amount, address
        case createdAt = "created_at"
    }
}

struct WithdrawPointsResponseRelationships: Codable {
    let balance: WithdrawPointsResponseBalance
}

struct WithdrawPointsResponseBalance: Codable {
    let data: WithdrawPointsResponseBalanceData
}

struct WithdrawPointsResponseBalanceData: Codable {
    let id, type: String
}

struct WithdrawPointsResponseIncluded: Codable {
    let id, type: String
    let attributes: WithdrawPointsResponseIncludedAttributes
}

struct WithdrawPointsResponseIncludedAttributes: Codable {
    let amount: Int
    let isDisabled: Bool
    let createdAt, updatedAt, rank: Int
    let activeReferralCodes, consumedReferralCodes: [String]
    let level: Int

    enum CodingKeys: String, CodingKey {
        case amount
        case isDisabled = "is_disabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rank
        case activeReferralCodes = "active_referral_codes"
        case consumedReferralCodes = "consumed_referral_codes"
        case level
    }
}

struct GetEventResponse: Codable {
    let data: GetEventResponseData
}

struct GetEventsResponse: Codable {
    let data: [GetEventResponseData]
}

struct GetEventResponseData: Codable {
    let id, type: String
    let attributes: GetEventResponseAttributes
}

struct GetEventResponseAttributes: Codable {
    let status: String
    let createdAt, updatedAt: Int
    let meta: GetEventResponseMeta
    let pointsAmount: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case meta
        case pointsAmount = "points_amount"
    }
}

struct GetEventResponseMeta: Codable {
    let metaStatic: GetEventResponseStatic

    enum CodingKeys: String, CodingKey {
        case metaStatic = "static"
    }
}

struct GetEventResponseDynamic: Codable {
    let id: String
}

struct GetEventResponseStatic: Codable {
    let name: String
    let reward: Int
    let title, description, shortDescription, frequency: String
    let startsAt, expiresAt: Date?
    let actionURL: String?
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case name, reward, title, description
        case shortDescription = "short_description"
        case frequency
        case startsAt = "starts_at"
        case expiresAt = "expires_at"
        case actionURL = "action_url"
        case logo
    }
}

struct GetEventResponseRelationships: Codable {
    let balance: GetEventResponseBalance
}

struct GetEventResponseBalance: Codable {
    let data: GetEventResponseBalanceData
}

struct GetEventResponseBalanceData: Codable {
    let id, type: String
}

struct ClaimPointsForEvent: Codable {
    let data: ClaimPointsForEventData
    let included: [ClaimPointsForEventIncluded]
}

struct ClaimPointsForEventData: Codable {
    let id, type: String
    let attributes: ClaimPointsForEventDataAttributes
    let relationships: ClaimPointsForEventRelationships
}

struct ClaimPointsForEventDataAttributes: Codable {
    let status: String
    let createdAt, updatedAt: Int
    let meta: ClaimPointsForEventMeta
    let pointsAmount: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case meta
        case pointsAmount = "points_amount"
    }
}

struct ClaimPointsForEventMeta: Codable {
    let metaStatic: ClaimPointsForEventStatic

    enum CodingKeys: String, CodingKey {
        case metaStatic = "static"
    }
}

struct ClaimPointsForEventDynamic: Codable {
    let id: String
}

struct ClaimPointsForEventStatic: Codable {
    let name: String
    let reward: Int
    let title, description, shortDescription, frequency: String
    let startsAt, expiresAt: Date?
    let actionURL: String?
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case name, reward, title, description
        case shortDescription = "short_description"
        case frequency
        case startsAt = "starts_at"
        case expiresAt = "expires_at"
        case actionURL = "action_url"
        case logo
    }
}

struct ClaimPointsForEventRelationships: Codable {
    let balance: ClaimPointsForEventBalance
}

struct ClaimPointsForEventBalance: Codable {
    let data: ClaimPointsForEventBalanceData
}

struct ClaimPointsForEventBalanceData: Codable {
    let id, type: String
}

struct ClaimPointsForEventIncluded: Codable {
    let id, type: String
    let attributes: ClaimPointsForEventIncludedAttributes
}

struct ClaimPointsForEventIncludedAttributes: Codable {
    let amount: Int
    let isDisabled: Bool
    let createdAt, updatedAt, rank: Int
    let activeReferralCodes, consumedReferralCodes: [String]
    let level: Int

    enum CodingKeys: String, CodingKey {
        case amount
        case isDisabled = "is_disabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case rank
        case activeReferralCodes = "active_referral_codes"
        case consumedReferralCodes = "consumed_referral_codes"
        case level
    }
}

struct ClaimPointsForEventRequest: Codable {
    let data: ClaimPointsForEventRequestData
}

struct ClaimPointsForEventRequestData: Codable {
    let id, type: String
}

struct VerifyPassportResponse: Codable {
    let data: VerifyPassportResponseData
}

struct VerifyPassportResponseData: Codable {
    let id, type: String
    let attributes: VerifyPassportResponseAttributes
}

struct VerifyPassportResponseAttributes: Codable {
    let claimed: Bool
}

struct JoinRewardsProgramRequest: Codable {
    let data: JoinRewardsProgramRequestData
}

struct JoinRewardsProgramRequestData: Codable {
    let id, type: String
    let attributes: JoinRewardsProgramRequestAttributes
}

struct JoinRewardsProgramRequestAttributes: Codable {
    let anonymousId: String
    let country: String

    enum CodingKeys: String, CodingKey {
        case anonymousId = "anonymous_id"
        case country
    }
}

enum EventNames: String, Codable {
    case referralCommon = "referral_common"
    case passportScan = "passport_scan"
    case referralSpecific = "referral_specific"
    case beReferred = "be_referred"
    case freeWeekly = "free_weekly"
}

enum EventStatuses: String, Codable {
    case open
    case fulfilled
    case claimed
}
