import Identity
import Foundation

class User {
    let secretKey: Data
    let profile: IdentityProfile
    
    var status: Status {
        didSet {
            AppUserDefaults.shared.userStatus = status.rawValue
        }
    }
    
    var userReferalCode: String? {
        didSet {
            AppUserDefaults.shared.userRefarralCode = userReferalCode ?? ""
        }
    }
    
    required init(secretKey: Data, _ status: Status =  .unscanned) throws {
        self.secretKey = secretKey
        
        self.profile = try IdentityProfile().newProfile(secretKey)
        
        self.status = status
        
        let userReferalCode = AppUserDefaults.shared.userRefarralCode
        if !userReferalCode.isEmpty {
            self.userReferalCode = userReferalCode
        }
    }
    
    static func load() throws -> Self? {
        guard let secretKey = try AppKeychain.getValue(.privateKey) else { return nil }
        
        let status = Status(rawValue: AppUserDefaults.shared.userStatus) ?? .unscanned
        
        return try Self(secretKey: secretKey, status)
    }
    
    func save() throws {
        try AppKeychain.setValue(.privateKey, secretKey)
        AppUserDefaults.shared.userStatus = status.rawValue
    }
}

extension User {
    public enum Status: Int {
        case unscanned
        case passportScanned
    }
}
