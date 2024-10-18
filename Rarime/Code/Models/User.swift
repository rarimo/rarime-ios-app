import CloudKit
import Foundation
import Identity

class User {
    static let userCloudRecordType = "User"
    static let userCloudPrivateKeyKey = "privateKey"
    
    let secretKey: Data
    let profile: IdentityProfile
    
    var status: Status {
        didSet {
            AppUserDefaults.shared.userStatus = status.rawValue
        }
    }
    
    var userReferralCode: String? {
        didSet {
            AppUserDefaults.shared.userReferralCode = userReferralCode ?? ""
        }
    }
    
    var deferredReferralCode: String? {
        didSet {
            AppUserDefaults.shared.deferredReferralCode = deferredReferralCode ?? ""
        }
    }
    
    required init(secretKey: Data, _ status: Status = .unscanned) throws {
        self.secretKey = secretKey
        
        self.profile = try IdentityProfile().newProfile(secretKey)
        
        self.status = status
        
        let userReferralCode = AppUserDefaults.shared.userReferralCode
        if !userReferralCode.isEmpty {
            self.userReferralCode = userReferralCode
        }
        
        self.deferredReferralCode = AppUserDefaults.shared.deferredReferralCode
    }
    
    static func load() throws -> Self? {
        guard let secretKey = try AppKeychain.getValue(.privateKey) else { return nil }
        
        let status = Status(rawValue: AppUserDefaults.shared.userStatus) ?? .unscanned
        
        return try Self(secretKey: secretKey, status)
    }
    
    static func loadFromCloud() async throws -> Self? {
        let query = CKQuery(recordType: userCloudRecordType, predicate: NSPredicate(value: true))
        
        let records = try await CloudStorage.shared.fetchRecords(query)
        
        guard let record = records.last else { return nil }
        
        guard let privateKey = record.value(forKey: userCloudPrivateKeyKey) as? Data else {
            throw "User private key not found in cloud"
        }
        
        let status = Status(rawValue: AppUserDefaults.shared.userStatus) ?? .unscanned
        
        return try Self(secretKey: privateKey, status)
    }
    
    func save() throws {
        try AppKeychain.setValue(.privateKey, secretKey)
        AppUserDefaults.shared.userStatus = status.rawValue
    }
    
    func saveUserPrivateKeyToCloud() async throws -> Bool {
        let query = CKQuery(recordType: User.userCloudRecordType, predicate: NSPredicate(value: true))
        
        let records = try await CloudStorage.shared.fetchRecords(query)
        
        let record = CKRecord(recordType: User.userCloudRecordType)
        record.setValue(secretKey, forKey: User.userCloudPrivateKeyKey)
        
        try await CloudStorage.shared.saveRecord(record)
        
        return true
    }
}

extension User {
    public enum Status: Int {
        case unscanned
        case passportScanned
        case passportVerified
    }
}
