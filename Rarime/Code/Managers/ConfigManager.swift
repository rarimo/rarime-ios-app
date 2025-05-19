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
        let privacyPolicyURL: URL
        let termsOfUseURL: URL
        let version: String
        let generalNotificationTopic: String
        let claimableNotificationTopic: String

        init() {
            do {
                self.privacyPolicyURL = try readURLFromInfoPlist(key: "PRIVACY_POLICY_URL")
                self.termsOfUseURL = try readURLFromInfoPlist(key: "TERMS_OF_USE_URL")
                self.version = try readFromInfoPlist(key: "CFBundleShortVersionString")
                self.generalNotificationTopic = try readFromInfoPlist(key: "GENERAL_NOTIFICATION_TOPIC")
                self.claimableNotificationTopic = try readFromInfoPlist(key: "CLAIMABLE_NOTIFICATION_TOPIC")
            } catch {
                fatalError("ConfigManager.General init error: \(error.localizedDescription)")
            }
        }
    }
}

extension ConfigManager {
    class API {
        let relayerURL: URL
        let evmRpcURL: URL
        let registerContractAddress: String
        let registrationSimpleContractAddress: String
        let certificatesSmtContractAddress: String
        let registrationSmtContractAddress: String
        let stateKeeperContractAddress: String
        let cosmosRpcURL: URL
        let pointsServiceURL: URL
        let authorizeURL: URL
        let referralURL: URL
        let joinRewardsKey: String
        let defaultReferralCode: String
        let lightSignaturePrivateKey: String
        let proposalsStateContractAddress: String
        let multicall3ContractAddress: String
        let ipfsNodeURL: URL
        let votingWebsiteURL: URL
        let votingRelayerURL: URL
        let votingRpcURL: URL
        let votingRegistartionSmtContractAddress: String

        init() {
            do {
                self.relayerURL = try readURLFromInfoPlist(key: "RELAYER_URL")
                self.evmRpcURL = try readURLFromInfoPlist(key: "EVM_RPC_URL")
                self.registerContractAddress = try readFromInfoPlist(key: "REGISTER_CONTRACT_ADDRESS")
                self.registrationSimpleContractAddress = try readFromInfoPlist(key: "REGISTRATION_SIMPLE_CONTRACT_ADRRESS")
                self.certificatesSmtContractAddress = try readFromInfoPlist(key: "CERTIFICATES_SMT_CONTRACT_ADDRESS")
                self.registrationSmtContractAddress = try readFromInfoPlist(key: "REGISTRATION_SMT_CONTRACT_ADDRESS")
                self.stateKeeperContractAddress = try readFromInfoPlist(key: "STATE_KEEPER_CONTRACT_ADDRESS")
                self.cosmosRpcURL = try readURLFromInfoPlist(key: "COSMOS_RPC_URL")
                self.pointsServiceURL = try readURLFromInfoPlist(key: "POINTS_SERVICE_URL")
                self.authorizeURL = try readURLFromInfoPlist(key: "AUTHORIZE_URL")
                self.referralURL = try readURLFromInfoPlist(key: "REFERRAL_URL")
                self.joinRewardsKey = try readFromInfoPlist(key: "JOIN_REWARDS_KEY")
                self.defaultReferralCode = try readFromInfoPlist(key: "DEFAULT_REFERRAL_CODE")
                self.lightSignaturePrivateKey = try readFromInfoPlist(key: "LIGHT_SIGNATURE_PRIVATE_KEY")
                self.proposalsStateContractAddress = try readFromInfoPlist(key: "PROPOSALS_STATE_CONTRACT_ADDRESS")
                self.multicall3ContractAddress = try readFromInfoPlist(key: "MULTICALL3_CONTRACT_ADDRESS")
                self.ipfsNodeURL = try readURLFromInfoPlist(key: "IPFS_NODE_URL")
                self.votingWebsiteURL = try readURLFromInfoPlist(key: "VOTING_WEBSITE_URL")
                self.votingRelayerURL = try readURLFromInfoPlist(key: "VOTING_RELAYER_URL")
                self.votingRpcURL = try readURLFromInfoPlist(key: "VOTING_RPC_URL")
                self.votingRegistartionSmtContractAddress = try readFromInfoPlist(key: "VOTING_REGISTRATION_SMT_CONTRACT_ADDRESS")
            } catch {
                fatalError("ConfigManager.API init error: \(error.localizedDescription)")
            }
        }
    }
}

extension ConfigManager {
    class Cosmos {
        let chainId: String
        let denom: String
        let rpcIp: String

        init() {
            do {
                self.chainId = try readFromInfoPlist(key: "CHAIN_ID")
                self.denom = try readFromInfoPlist(key: "DENOM")
                self.rpcIp = try readFromInfoPlist(key: "RPC_IP")
            } catch {
                fatalError("ConfigManager.Cosmos init error: \(error.localizedDescription)")
            }
        }
    }
}

extension ConfigManager {
    class CertificatesStorage {
        let icaoCosmosRpc: String
        let masterCertificatesBucketname: String
        let masterCertificatesFilename: String

        init() {
            do {
                self.icaoCosmosRpc = try readFromInfoPlist(key: "ICAO_COSMOS_RPC")
                self.masterCertificatesBucketname = try readFromInfoPlist(key: "MASTER_CERTIFICATES_BUCKETNAME")
                self.masterCertificatesFilename = try readFromInfoPlist(key: "MASTER_CERTIFICATES_FILENAME")
            } catch {
                fatalError("ConfigManager.CertificatesStorage init error: \(error.localizedDescription)")
            }
        }
    }
}

extension ConfigManager {
    class CircuitData {
        let circuitDataURLs: [String: URL]

        init() {
            do {
                self.circuitDataURLs = try readURLDictionaryFromInfoPlist(key: "CIRCUIT_DATA_URLS")
            } catch {
                fatalError("ConfigManager.CircuitData init error: \(error)")
            }
        }
    }
}

extension ConfigManager {
    class Feedback {
        let feedbackEmail: String

        init() {
            do {
                self.feedbackEmail = try readFromInfoPlist(key: "FEEDBACK_EMAIL")
            } catch {
                fatalError("ConfigManager.Feedback init error: \(error.localizedDescription)")
            }
        }
    }
}

extension ConfigManager {
    class AppsFlyer {
        let appId: String
        let devKey: String

        init() {
            do {
                self.appId = try readFromInfoPlist(key: "APPSFLYER_APP_ID")
                self.devKey = try readFromInfoPlist(key: "APPSFLYER_DEV_KEY")
            } catch {
                fatalError("ConfigManager.AppsFlyer init error: \(error.localizedDescription)")
            }
        }
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
