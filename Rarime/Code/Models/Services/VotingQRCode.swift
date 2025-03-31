import Foundation
import Alamofire

class VotingQRCode {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func getLink(_ jwt: JWT, _ linkId: String) async throws -> GetLinkResponse {
        let headers = HTTPHeaders(
            [
                HTTPHeader(name: "Authorization", value: "Bearer \(jwt.raw)")
            ]
        )
        print("headers", headers)

        let requestUrl = url.appendingPathComponent("integrations/qr-link-manager-svc/v1/public/links/\(linkId)")
        print("requestUrl", requestUrl)
        let response = try await AF.request(requestUrl, headers: headers)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(GetLinkResponse.self)
            .result
            .get()

        return response
    }
}

struct GetLinkResponse: Codable {
    var data: GetLinkResponseData
}

struct GetLinkResponseData: Codable {
    let id, type: String
    var attributes: QRCodeRaw
}

struct QRCodeRaw: Codable {
    let metadata: String
    let scanCount: Int
    let scanLimit: Int
    let active: Bool
    let expiresAt: Int
    let createdAt: Int
    let url: URL

    enum CodingKeys: String, CodingKey {
        case metadata
        case scanCount = "scan_count"
        case scanLimit = "scan_limit"
        case active
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case url
    }
}
