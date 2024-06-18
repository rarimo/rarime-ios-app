import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    let general = General()
    let api = API()
    let cosmos = Cosmos()
    let certificatesStorage = CertificatesStorage()
    let feedback = Feedback()
    let circuitData = CircuitData()
}

extension ConfigManager {
    class General {
        let privacyPolicyURL: URL
        let termsOfUseURL: URL
        let version: String

        init() {
            do {
                self.privacyPolicyURL = try readURLFromInfoPlist(key: "PRIVACY_POLICY_URL")
                self.termsOfUseURL = try readURLFromInfoPlist(key: "TERMS_OF_USE_URL")
                self.version = try readFromInfoPlist(key: "CFBundleShortVersionString")
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
        let certificatesSmtContractAddress: String
        let stateKeeperContractAddress: String
        let cosmosRpcURL: URL
        let pointsServiceURL: URL
        let authorizeURL: URL

        init() {
            do {
                self.relayerURL = try readURLFromInfoPlist(key: "RELAYER_URL")
                self.evmRpcURL = try readURLFromInfoPlist(key: "EVM_RPC_URL")
                self.registerContractAddress = try readFromInfoPlist(key: "REGISTER_CONTRACT_ADDRESS")
                self.certificatesSmtContractAddress = try readFromInfoPlist(key: "CERTIFICATES_SMT_CONTRACT_ADDRESS")
                self.stateKeeperContractAddress = try readFromInfoPlist(key: "STATE_KEEPER_CONTRACT_ADDRESS")
                self.cosmosRpcURL = try readURLFromInfoPlist(key: "COSMOS_RPC_URL")
                self.pointsServiceURL = try readURLFromInfoPlist(key: "POINTS_SERVICE_URL")
                self.authorizeURL = try readURLFromInfoPlist(key: "AUTHORIZE_URL")
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

fileprivate func readFromInfoPlist<T>(key: String) throws -> T {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? T else {
        throw "Couldn't find \(key) in Info.plist"
    }
    
    if let value = value as? String {
        return normalizeInfoPlistString(value) as! T
    }

    return value
}

fileprivate func readURLFromInfoPlist(key: String) throws -> URL {
    let value: String = try readFromInfoPlist(key: key)

    guard let url = URL(string: value) else { throw "\(key) isn't URL" }

    return url
}

fileprivate func readURLDictionaryFromInfoPlist(key: String) throws -> [String: URL] {
    let value: [String: String] = try readFromInfoPlist(key: key)
    
    var result: [String: URL] = [:]
    for item in value {
        guard let url = URL(string: normalizeInfoPlistString(item.value)) else { throw "\(key) isn't URL" }
        
        result[item.key] = url
    }

    return result
}

fileprivate func normalizeInfoPlistString(_ value: String) -> String {
    return value.starts(with: "\"")
        ? String(value.dropFirst().dropLast())
        : value
}
