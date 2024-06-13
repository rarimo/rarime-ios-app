import Foundation

class JWT {
    let raw: String
    
    let header: JWTHeader
    let payload: JWTPayload
    
    init(_ raw: String) throws {
        self.raw = raw
        
        let parts = raw.components(separatedBy: ".")
        
        let decoder = JSONDecoder()
        
        let headerData = Data(base64Encoded: parts[0], options: .ignoreUnknownCharacters) ?? Data()
        let payloadData = Data(base64Encoded: parts[1], options: .ignoreUnknownCharacters) ?? Data()
        
        self.header = try decoder.decode(JWTHeader.self, from: headerData)
        self.payload = try decoder.decode(JWTPayload.self, from: payloadData)
    }
    
    var isExpiringIn5Minutes: Bool {
        let now = Int(Date().timeIntervalSince1970)
        return payload.exp - now < 300
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
