import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    let general = General()
    let notifications = Notifications()
    let contracts = Contracts()
    let evm = EVM()
    let freedomTool = FreedomTool()
    let appsFlyer = AppsFlyer()
    let secrets = Secrets()
}

extension ConfigManager {
    class General {
        let version: String = try! readFromInfoPlist(key: "CFBundleShortVersionString")
        let feedbackEmail: String = try! readFromInfoPlist(key: "FEEDBACK_EMAIL")
        let defaultReferralCode: String = try! readFromInfoPlist(key: "DEFAULT_REFERRAL_CODE")
        let webAppURL: URL = try! readURLFromInfoPlist(key: "WEB_APP_URL")
        let termsOfUseURL: URL = try! readURLFromInfoPlist(key: "TERMS_OF_USE_URL")
        let privacyPolicyURL: URL = try! readURLFromInfoPlist(key: "PRIVACY_POLICY_URL")
        let appApiURL: URL = try! readURLFromInfoPlist(key: "APP_API_URL")
    }
}

extension ConfigManager {
    class Notifications {
        let generalTopic: String = try! readFromInfoPlist(key: "GENERAL_NOTIFICATION_TOPIC")
        let claimableTopic: String = try! readFromInfoPlist(key: "CLAIMABLE_NOTIFICATION_TOPIC")
    }
}

extension ConfigManager {
    class Contracts {
        let registration2Address: String = try! readFromInfoPlist(key: "REGISTRATION2_CONTRACT_ADDRESS")
        let registrationSimpleAddress: String = try! readFromInfoPlist(key: "REGISTRATION_SIMPLE_CONTRACT_ADRRESS")
        let certificatesSmtAddress: String = try! readFromInfoPlist(key: "CERTIFICATES_SMT_CONTRACT_ADDRESS")
        let registrationSmtAddress: String = try! readFromInfoPlist(key: "REGISTRATION_SMT_CONTRACT_ADDRESS")
        let stateKeeperAddress: String = try! readFromInfoPlist(key: "STATE_KEEPER_CONTRACT_ADDRESS")
        let multicall3Address: String = try! readFromInfoPlist(key: "MULTICALL3_CONTRACT_ADDRESS")
        let votingRegistrationSmtAddress: String = try! readFromInfoPlist(key: "VOTING_REGISTRATION_SMT_CONTRACT_ADDRESS")
        let proposalsStateAddress: String = try! readFromInfoPlist(key: "PROPOSALS_STATE_CONTRACT_ADDRESS")
        let faceRegistryAddress: String = try! readFromInfoPlist(key: "FACE_REGISTRY_CONTRACT_ADDRESS")
        let guessCelebrityAddress: String = try! readFromInfoPlist(key: "GUESS_CELEBRITY_CONTRACT_ADDRESS")
    }
}

extension ConfigManager {
    class EVM {
        let rpcURL: URL = try! readURLFromInfoPlist(key: "EVM_RPC_URL")
        let chainId: UInt64 = try! readUInt64FromInfoPlist(key: "EVM_CHAIN_ID")
        let scanUrl: URL = try! readURLFromInfoPlist(key: "EVM_SCAN_URL")
        let scanApiUrl: URL = try! readURLFromInfoPlist(key: "EVM_SCAN_API_URL")
    }
}

extension ConfigManager {
    class FreedomTool {
        let rpcURL: URL = try! readURLFromInfoPlist(key: "FREEDOM_TOOL_RPC_URL")
        let ipfsNodeURL: URL = try! readURLFromInfoPlist(key: "FREEDOM_TOOL_IPFS_NODE_URL")
        let websiteURL: URL = try! readURLFromInfoPlist(key: "FREEDOM_TOOL_WEBSITE_URL")
        let apiURL: URL = try! readURLFromInfoPlist(key: "FREEDOM_TOOL_API_URL")
    }
}

extension ConfigManager {
    class AppsFlyer {
        let appId: String = try! readFromInfoPlist(key: "APPSFLYER_APP_ID")
        let devKey: String = try! readFromInfoPlist(key: "APPSFLYER_DEV_KEY")
    }
}

extension ConfigManager {
    class Secrets {
        let joinRewardsKey: String = try! readFromInfoPlist(key: "JOIN_REWARDS_KEY")
        let lightSignaturePrivateKey: String = try! readFromInfoPlist(key: "LIGHT_SIGNATURE_PRIVATE_KEY")
    }
}

private func readFromInfoPlist<T>(key: String) throws -> T {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
        throw "Couldn't find \(key) in Info.plist"
    }

    if let value = value as? String {
        return normalizeInfoPlistString(value) as! T
    }

    return value
}

private func readURLFromInfoPlist(key: String) throws -> URL {
    let value: String = try readFromInfoPlist(key: key)

    guard let url = URL(string: value) else { throw "\(key) isn't URL" }

    return url
}

private func readUInt64FromInfoPlist(key: String) throws -> UInt64 {
    let value: String = try readFromInfoPlist(key: key)

    guard let uint64 = UInt64(value) else { throw "\(key) isn't UInt64" }

    return uint64
}

private func normalizeInfoPlistString(_ value: String) -> String {
    return value.starts(with: "\"")
        ? String(value.dropFirst().dropLast())
        : value
}
