import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    let general = General()
    let api = API()
    let cosmos = Cosmos()
    let certificatesStorage = CertificatesStorage()
    let feedback = Feedback()
    let circuitData = CircuitData()
    let appsFlyer = AppsFlyer()
    let noirCircuitData = NoirCircuitData()
}

extension ConfigManager {
    class General {
        let privacyPolicyURL: URL = try! readURLFromInfoPlist(key: "PRIVACY_POLICY_URL")
        let termsOfUseURL: URL = try! readURLFromInfoPlist(key: "TERMS_OF_USE_URL")
        let airdropTerms: URL = try! readURLFromInfoPlist(key: "AIRDROP_TERMS_URL")
        let version: String = try! readFromInfoPlist(key: "CFBundleShortVersionString")
        let generalNotificationTopic: String = try! readFromInfoPlist(key: "GENERAL_NOTIFICATION_TOPIC")
        let claimableNotificationTopic: String = try! readFromInfoPlist(key: "CLAIMABLE_NOTIFICATION_TOPIC")
        let downloadbleFileURLs: [String: URL] = try! readURLDictionaryFromInfoPlist(key: "DOWNLOADABLE_FILE_URLS")
    }
}

extension ConfigManager {
    class API {
        let relayerURL: URL = try! readURLFromInfoPlist(key: "RELAYER_URL")
        let evmRpcURL: URL = try! readURLFromInfoPlist(key: "EVM_RPC_URL")
        let registerContractAddress: String = try! readFromInfoPlist(key: "REGISTER_CONTRACT_ADDRESS")
        let registrationSimpleContractAddress: String = try! readFromInfoPlist(key: "REGISTRATION_SIMPLE_CONTRACT_ADRRESS")
        let certificatesSmtContractAddress: String = try! readFromInfoPlist(key: "CERTIFICATES_SMT_CONTRACT_ADDRESS")
        let registrationSmtContractAddress: String = try! readFromInfoPlist(key: "REGISTRATION_SMT_CONTRACT_ADDRESS")
        let stateKeeperContractAddress: String = try! readFromInfoPlist(key: "STATE_KEEPER_CONTRACT_ADDRESS")
        let pointsServiceURL: URL = try! readURLFromInfoPlist(key: "POINTS_SERVICE_URL")
        let authorizeURL: URL = try! readURLFromInfoPlist(key: "AUTHORIZE_URL")
        let referralURL: URL = try! readURLFromInfoPlist(key: "REFERRAL_URL")
        let joinRewardsKey: String = try! readFromInfoPlist(key: "JOIN_REWARDS_KEY")
        let defaultReferralCode: String = try! readFromInfoPlist(key: "DEFAULT_REFERRAL_CODE")
        let lightSignaturePrivateKey: String = try! readFromInfoPlist(key: "LIGHT_SIGNATURE_PRIVATE_KEY")
        let proposalsStateContractAddress: String = try! readFromInfoPlist(key: "PROPOSALS_STATE_CONTRACT_ADDRESS")
        let multicall3ContractAddress: String = try! readFromInfoPlist(key: "MULTICALL3_CONTRACT_ADDRESS")
        let ipfsNodeURL: URL = try! readURLFromInfoPlist(key: "IPFS_NODE_URL")
        let votingWebsiteURL: URL = try! readURLFromInfoPlist(key: "VOTING_WEBSITE_URL")
        let votingRelayerURL: URL = try! readURLFromInfoPlist(key: "VOTING_RELAYER_URL")
        let votingRpcURL: URL = try! readURLFromInfoPlist(key: "VOTING_RPC_URL")
        let votingRegistartionSmtContractAddress: String = try! readFromInfoPlist(key: "VOTING_REGISTRATION_SMT_CONTRACT_ADDRESS")
        let faceRegistryContractAddress: String = try! readFromInfoPlist(key: "FACE_REGISTRY_CONTRACT_ADDRESS")
        let guessCelebrityGameContractAddress: String = try! readFromInfoPlist(key: "GUESS_CELEBRITY_GAME_CONTRACT_ADDRESS")
        let evmChainId: UInt64 = try! readUInt64FromInfoPlist(key: "EVM_CHAIN_ID")
    }
}

extension ConfigManager {
    class Cosmos {
        let chainId: String = try! readFromInfoPlist(key: "CHAIN_ID")
        let denom: String = try! readFromInfoPlist(key: "DENOM")
        let rpcIp: String = try! readFromInfoPlist(key: "RPC_IP")
    }
}

extension ConfigManager {
    class CertificatesStorage {
        let icaoCosmosRpc: String = try! readFromInfoPlist(key: "ICAO_COSMOS_RPC")
        let masterCertificatesBucketname: String = try! readFromInfoPlist(key: "MASTER_CERTIFICATES_BUCKETNAME")
        let masterCertificatesFilename: String = try! readFromInfoPlist(key: "MASTER_CERTIFICATES_FILENAME")
    }
}

extension ConfigManager {
    class CircuitData {
        let circuitDataURLs: [String: URL] = try! readURLDictionaryFromInfoPlist(key: "CIRCUIT_DATA_URLS")
        let zkeyURLs: [String: URL] = try! readURLDictionaryFromInfoPlist(key: "ZKEY_URLS")
    }
}

extension ConfigManager {
    class Feedback {
        let feedbackEmail: String = try! readFromInfoPlist(key: "FEEDBACK_EMAIL")
    }
}

extension ConfigManager {
    class AppsFlyer {
        let appId: String = try! readFromInfoPlist(key: "APPSFLYER_APP_ID")
        let devKey: String = try! readFromInfoPlist(key: "APPSFLYER_DEV_KEY")
    }
}

extension ConfigManager {
    class NoirCircuitData {
        let noirTrustedSetupURL: URL = try! readURLFromInfoPlist(key: "NOIR_TRUSTED_SETUP_URL")
        let noirCircuitDataURLs: [String: URL] = try! readURLDictionaryFromInfoPlist(key: "NOIR_CIRCUIT_DATA_URLS")
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

private func readURLDictionaryFromInfoPlist(key: String) throws -> [String: URL] {
    let value: [String: String] = try readFromInfoPlist(key: key)

    var result: [String: URL] = [:]
    for item in value {
        guard let url = URL(string: normalizeInfoPlistString(item.value)) else { throw "\(key) isn't URL" }

        result[item.key] = url
    }

    return result
}

private func normalizeInfoPlistString(_ value: String) -> String {
    return value.starts(with: "\"")
        ? String(value.dropFirst().dropLast())
        : value
}
