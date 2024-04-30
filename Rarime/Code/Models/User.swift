import Identity
import Foundation

class User {    
    let secretKey: Data
    let profile: IdentityProfile
    
    required init(secretKey: Data) throws {
        self.secretKey = secretKey
        
        self.profile = try IdentityProfile().newProfile(secretKey)
    }
    
    static func load() throws -> Self? {
        guard let secretKey = try AppKeychain.getValue(.privateKey) else { return nil }
        
        return try Self(secretKey: secretKey)
    }
    
    func save() throws {
        try AppKeychain.setValue(.privateKey, secretKey)
    }
}
