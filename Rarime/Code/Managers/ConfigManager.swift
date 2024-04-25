import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    // TODO: Create General subclass and move this there
    let privacyPolicyURL: URL
    let termsOfUseURL: URL
    let version: String
    
    let circuitData: CircuitData
    let api: API

    init() {
        do {
            guard
                let privacyPolicyURLRaw = Bundle.main.object(forInfoDictionaryKey: "PRIVACY_POLICY_URL") as? String,
                let termsOfUseURLRaw = Bundle.main.object(forInfoDictionaryKey: "TERMS_OF_USE_URL") as? String,
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            else {
                throw "some config value aren't initialized"
            }

            guard
                let privacyPolicyURL = URL(string: String(privacyPolicyURLRaw.dropFirst().dropLast())),
                let termsOfUseURL = URL(string: String(termsOfUseURLRaw.dropFirst().dropLast()))
            else {
                throw "PRIVACY_POLICY_URL and/or TERMS_OF_USE_URL aren't URLs"
            }

            self.privacyPolicyURL = privacyPolicyURL
            self.termsOfUseURL = termsOfUseURL
            self.version = version
            
            self.circuitData = CircuitData()
            self.api = API()
        } catch {
            fatalError("ConfigManager init error: \(error)")
        }
    }
}

extension ConfigManager {
    class CircuitData {
        let registerIdentityCircuitDataURLs: [URL]
        
        init() {
            do {
                guard
                    let registerIdentityCircuitDataURLsRaw = Bundle.main.object(forInfoDictionaryKey: "REGISTER_IDENTITY_CIRCUIT_DATA_URLS") as? [String]
                else {
                    throw "failed to read REGISTER_IDENTITY_CIRCUIT_DATA_URLS"
                }
                
                var registerIdentityCircuitDataURLs: [URL] = []
                for registerIdentityCircuitDataURLRaw in registerIdentityCircuitDataURLsRaw {
                    guard
                        let registerIdentityCircuitDataURL = URL(string: String(registerIdentityCircuitDataURLRaw.dropFirst().dropLast()))
                    else {
                        throw "invalid URL, REGISTER_IDENTITY_CIRCUIT_DATA_URL: \(registerIdentityCircuitDataURLRaw)"
                    }
                    
                    registerIdentityCircuitDataURLs.append(registerIdentityCircuitDataURL)
                }
                
                self.registerIdentityCircuitDataURLs = registerIdentityCircuitDataURLs
            } catch {
                fatalError("ConfigManager.CircuitData init error: \(error)")
            }
        }
    }
}

extension ConfigManager {
    class API {
        let relayerURL: URL
        let evmRpcURL: URL
        let registerContractAddress: String
        
        init() {
            do {
                guard
                    var relayerURLRaw = Bundle.main.object(forInfoDictionaryKey: "RELAYER_URL") as? String,
                    var evmRpcURLRaw = Bundle.main.object(forInfoDictionaryKey: "EVM_RPC_URL") as? String,
                    var registerContractAddressRaw = Bundle.main.object(forInfoDictionaryKey: "REGISTER_CONTRACT_ADDRESS") as? String
                else {
                    throw "some config value aren't initialized"
                }
            
                guard
                    let relayerURL = URL(string: String(relayerURLRaw.dropFirst().dropLast())),
                    let evmRpcURL = URL(string: String(evmRpcURLRaw.dropFirst().dropLast()))
                else {
                    throw "some of config entries aren't URLs"
                }
                
                self.relayerURL = relayerURL
                self.evmRpcURL = evmRpcURL
                self.registerContractAddress = registerContractAddressRaw
            } catch {
                fatalError("ConfigManager.API init error: \(error)")
            }
        }
    }
}
