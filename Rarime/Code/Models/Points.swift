import Foundation
import Alamofire

class Points {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func createPointsBalance(_ nullifier: String, _ refaralCode: String) async throws -> CreatePointBalanceRequest {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances")
        
        let requestPayload = CreatePointBalanceRequest(
            data: CreatePointBalanceRequestData(
                id: nullifier,
                type: "create_balance",
                attributes: CreatePointBalanceRequestAttributes(
                    referredBy: refaralCode
                )
            )
        )
        
        let response = try await AF.request(requestUrl, method: .post)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(CreatePointBalanceRequest.self)
            .result
            .get()
        
        return response
    }
    
    func getLeaderboard(_ pageLimit: Int, _ pageNumber: Int, _ pageOrder: String = "desc") async throws -> GetLeaderboardResponse {
        let query = [
            URLQueryItem(name: "page[limit]", value: String(pageLimit)),
            URLQueryItem(name: "page[number]", value: String(pageNumber)),
            URLQueryItem(name: "page[order]", value: pageOrder)
        ]
        
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances").appending(queryItems: query)
        
        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetLeaderboardResponse.self)
            .result
            .get()
        
        return response
    }
    
    func getPointsBalance(_ nullifier: String, _ rank: Optional<Bool> = nil , _ referral_codes: Optional<Bool> = nil) async throws -> GetPointsBalanceResponse {
        var query = [URLQueryItem]()
        
        if let rank = rank {
            query.append(URLQueryItem(name: "rank", value: String(rank)))
        }
        
        if let referral_codes = referral_codes {
            query.append(URLQueryItem(name: "referral_codes", value: String(referral_codes)))
        }
        
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifier)").appending(queryItems: query)
        
        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetPointsBalanceResponse.self)
            .result
            .get()
        
        return response
    }
    
    func activatePointsBalance(_ nullifier: String, _ refaralCode: String) async throws -> CreatePointBalanceRequest {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifier)")
        
        let requestPayload = CreatePointBalanceRequest(
            data: CreatePointBalanceRequestData(
                id: nullifier,
                type: "update_balance",
                attributes: CreatePointBalanceRequestAttributes(
                    referredBy: refaralCode
                )
            )
        )
        
        let response = try await AF.request(requestUrl, method: .patch)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(CreatePointBalanceRequest.self)
            .result
            .get()
        
        return response
    }
    
    func verifyPassport(_ nullifier: String, _ zkProof: ZkProof) async throws -> VerifyPassportRequest {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/balances/\(nullifier)/verifypassport")
        
        let requestPayload = VerifyPassportRequest(
            data: VerifyPassportRequestData(
                id: nullifier,
                type: "verify_passport",
                attributes: VerifyPassportRequestAttributes(
                    proof: zkProof
                )
            )
        )
        
        let response = try await AF.request(requestUrl, method: .post)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(VerifyPassportRequest.self)
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
        
        let response = try await AF.request(requestUrl, method: .post)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(WithdrawPointsResponse.self)
            .result
            .get()
        
        return response
    }
    
    func listEvents(
        _ nullifier: String,
        _ filterStatus: Optional<[String]> = nil,
        _ filterMetaStaticName: Optional<[String]> = nil,
        _ count: Optional<Bool> = nil,
        _ pageLimit: Optional<Int> = nil,
        _ pageNumber: Optional<Int> = nil,
        _ pageOrder: Optional<String> = nil
    ) async throws -> GetEventsResponse {
        var query = [
            URLQueryItem(name: "filter[nullifier]", value: nullifier)
        ]
        
        if let filterStatus = filterStatus {
            query.append(contentsOf: filterStatus.map { URLQueryItem(name: "filter[status]", value: $0) })
        }
        
        if let filterMetaStaticName = filterMetaStaticName {
            query.append(contentsOf: filterMetaStaticName.map { URLQueryItem(name: "filter[meta.static.name]", value: $0) })
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
        
        let response = try await AF.request(requestUrl)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetEventsResponse.self)
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
    
    func claimPointsForEvent(_ eventId: String) async throws -> ClaimPointsForEvent {
        let requestUrl = url.appendingPathComponent("integrations/rarime-points-svc/v1/public/events/\(eventId)")
        
        let requestPayload = ClaimPointsForEventRequest(
            data: ClaimPointsForEventRequestData(
                id: eventId,
                type: "claim_points"
            )
        )
        
        let response = try await AF.request(requestUrl, method: .post)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(ClaimPointsForEvent.self)
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

struct GetLeaderboardResponse: Codable {
    let data: [GetLeaderboardResponseData]
}

struct GetLeaderboardResponseData: Codable {
    let id, type: String
    let attributes: GetLeaderboardResponseAttributes
}

struct GetLeaderboardResponseAttributes: Codable {
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

struct GetPointsBalanceResponse: Codable {
    let data: GetPointsBalanceResponseData
}

struct GetPointsBalanceResponseData: Codable {
    let id, type: String
    let attributes: GetPointsBalanceResponseAttributes
}

struct GetPointsBalanceResponseAttributes: Codable {
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

struct VerifyPassportRequest: Codable {
    let data: VerifyPassportRequestData
}

struct VerifyPassportRequestData: Codable {
    let id, type: String
    let attributes: VerifyPassportRequestAttributes
}

struct VerifyPassportRequestAttributes: Codable {
    let proof: ZkProof
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
    let relationships: GetEventResponseRelationships
}

struct GetEventResponseAttributes: Codable {
    let status: String
    let createdAt, updatedAt: Int
    let meta: GetEventResponseMeta
    let pointsAmount: Int

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
    let metaDynamic: GetEventResponseDynamic

    enum CodingKeys: String, CodingKey {
        case metaStatic = "static"
        case metaDynamic = "dynamic"
    }
}

struct GetEventResponseDynamic: Codable {
    let id: String
}

struct GetEventResponseStatic: Codable {
    let name: String
    let reward: Int
    let title, description, shortDescription, frequency: String
    let startsAt, expiresAt: String
    let actionURL: String
    let logo: String

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
    let pointsAmount: Int

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
    let metaDynamic: ClaimPointsForEventDynamic

    enum CodingKeys: String, CodingKey {
        case metaStatic = "static"
        case metaDynamic = "dynamic"
    }
}

struct ClaimPointsForEventDynamic: Codable {
    let id: String
}

struct ClaimPointsForEventStatic: Codable {
    let name: String
    let reward: Int
    let title, description, shortDescription, frequency: String
    let startsAt, expiresAt: String
    let actionURL: String
    let logo: String

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