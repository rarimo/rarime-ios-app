import Foundation

class JWT: Codable {
    static let SOON = 300
    
    let raw: String
    
    let header: JWTHeader
    let payload: JWTPayload
    
    init(_ raw: String) throws {
        self.raw = raw
        
        let parts = raw.components(separatedBy: ".")
        
        let headerBase64 = parts[0]
        var payloadBase64 = parts[1]
        
        
        // Adds "=" characters to payloadBase64 to make it a multiple of 4
        let payloadRemainder = payloadBase64.count % 4
        if payloadRemainder > 0 {
            payloadBase64.append(String(repeating: "=", count: 4 - payloadRemainder))
        }
        
        let decoder = JSONDecoder()
        
        guard let headerData = Data(base64Encoded: headerBase64, options: .ignoreUnknownCharacters) else {
            throw NSError(domain: "JWT", code: 1, userInfo: ["message": "Invalid JWT header"])
        }
        
        guard let payloadData = Data(base64Encoded: payloadBase64, options: .ignoreUnknownCharacters) else {
            throw NSError(domain: "JWT", code: 2, userInfo: ["message": "Invalid JWT payload"])
        }
        
        self.header = try decoder.decode(JWTHeader.self, from: headerData)
        self.payload = try decoder.decode(JWTPayload.self, from: payloadData)
    }
    
    var isExpiringSoon: Bool {
        let now = Int(Date().timeIntervalSince1970)
        return payload.exp - now < JWT.SOON
    }
    
    var isExpired: Bool {
        let now = Int(Date().timeIntervalSince1970)
        return payload.exp < now
    }
}

struct JWTHeader: Codable {
    let alg: String
    let typ: String
}

struct JWTPayload: Codable {
    let exp: Int
    let sub: String
    let type: JWTTokenType
}

enum JWTTokenType: String, Codable {
    case access = "access"
    case refresh = "refresh"
}
