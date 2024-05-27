import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    let general: General
    let api: API
    let cosmos: Cosmos
    let certificatesStorage: CertificatesStorage
    let feedback: Feedback

    init() {
        self.general = General()
        self.api = API()
        self.cosmos = Cosmos()
        self.certificatesStorage = CertificatesStorage()
        self.feedback = Feedback()
    }
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
                self.version = try readStringFromInfoPlist(key: "CFBundleShortVersionString")
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
        let cosmosRpcURL: URL
        
        init() {
            do {
                self.relayerURL = try readURLFromInfoPlist(key: "RELAYER_URL")
                self.evmRpcURL = try readURLFromInfoPlist(key: "EVM_RPC_URL")
                self.registerContractAddress = try readStringFromInfoPlist(key: "REGISTER_CONTRACT_ADDRESS")
                self.cosmosRpcURL = try readURLFromInfoPlist(key: "COSMOS_RPC_URL")
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
                self.chainId = try readStringFromInfoPlist(key: "CHAIN_ID")
                self.denom = try readStringFromInfoPlist(key: "DENOM")
                self.rpcIp = try readStringFromInfoPlist(key: "RPC_IP")
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
                self.icaoCosmosRpc = try readStringFromInfoPlist(key: "ICAO_COSMOS_RPC")
                self.masterCertificatesBucketname = try readStringFromInfoPlist(key: "MASTER_CERTIFICATES_BUCKETNAME")
                self.masterCertificatesFilename = try readStringFromInfoPlist(key: "MASTER_CERTIFICATES_FILENAME")
            } catch {
                fatalError("ConfigManager.CertificatesStorage init error: \(error.localizedDescription)")
            }
        }
    }
}

extension ConfigManager {
    class Feedback {
        let feedbackEmail: String
        
        init() {
            do {
                self.feedbackEmail = try readStringFromInfoPlist(key: "FEEDBACK_EMAIL")
            } catch {
                fatalError("ConfigManager.Feedback init error: \(error.localizedDescription)")
            }
        }
    }
}

// Although we normally return an optional parameter when we get some value for a key,
// in our case it is better to throw an error to improve the readability of errors
fileprivate func readStringFromInfoPlist(key: String) throws -> String {
    guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
        throw "Couldn't find \(key) in Info.plist"
    }
    
    return String(value.dropFirst().dropLast())
}

fileprivate func readURLFromInfoPlist(key: String) throws -> URL {
    let value = try readStringFromInfoPlist(key: key)
    
    guard let url = URL(string: value) else { throw "\(key) isn't URL" }
    
    return url
}
