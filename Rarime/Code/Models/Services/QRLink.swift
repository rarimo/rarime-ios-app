import Foundation
import Alamofire

class QRLink {
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func scanQRLink(_ url: URL) async throws -> ScanQRLinkResponse {
        return try await AF.request(url)
            .validate(OpenApiError.catchInstance)
            .serializingDecodable(ScanQRLinkResponse.self)
            .result
            .get()
    }
}


struct QRCodeMetadata: Codable {
    let proposalId: Int
    
    enum CodingKeys: String, CodingKey {
        case proposalId = "proposal_id"
    }
}

struct ScanQRLinkResponse: Codable {
    let data: ScanQRLinkData
}

struct ScanQRLinkData: Codable {
    let id: String
    let type: String
    let attributes: ScanQRLinkAttributes
}

struct ScanQRLinkAttributes: Codable {
    let metadata: QRCodeMetadata
}
