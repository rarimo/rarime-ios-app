import KeychainAccess

enum AppKeychainItemKey: String {
    case passcode
    case privateKey
    case passport
}

class AppKeychain {
    private static let keychain = Keychain(service: "DistributedLab.Rarime")

    static func getValue(_ key: AppKeychainItemKey) throws -> String? {
        try keychain.get(key.rawValue)
    }

    static func setValue(_ key: AppKeychainItemKey, _ value: String) throws {
        try keychain.set(value, key: key.rawValue)
    }

    static func removeValue(_ key: AppKeychainItemKey) throws {
        try keychain.remove(key.rawValue)
    }
}
