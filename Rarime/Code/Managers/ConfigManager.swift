import Foundation

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    // TODO: Create General subclass and move this there
    let privacyPolicyURL: URL
    let termsOfUseURL: URL
    let version: String
    
    let api: API
    let cosmos: Cosmos

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
            
            self.api = API()
            self.cosmos = Cosmos()
        } catch {
            fatalError("ConfigManager init error: \(error)")
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
                guard
                    let relayerURLRaw = Bundle.main.object(forInfoDictionaryKey: "RELAYER_URL") as? String,
                    let evmRpcURLRaw = Bundle.main.object(forInfoDictionaryKey: "EVM_RPC_URL") as? String,
                    let registerContractAddressRaw = Bundle.main.object(forInfoDictionaryKey: "REGISTER_CONTRACT_ADDRESS") as? String,
                    let cosmosRpcURLRaw = Bundle.main.object(forInfoDictionaryKey: "COSMOS_RPC_URL") as? String
                else {
                    throw "some config value aren't initialized"
                }
            
                guard
                    let relayerURL = URL(string: String(relayerURLRaw.dropFirst().dropLast())),
                    let evmRpcURL = URL(string: String(evmRpcURLRaw.dropFirst().dropLast())),
                    let cosmosRpcURL = URL(string: String(cosmosRpcURLRaw.dropFirst().dropLast()))
                else {
                    throw "some of config entries aren't URLs"
                }
                
                self.relayerURL = relayerURL
                self.evmRpcURL = evmRpcURL
                self.registerContractAddress = String(registerContractAddressRaw.dropFirst().dropLast())
                self.cosmosRpcURL = cosmosRpcURL
            } catch {
                fatalError("ConfigManager.API init error: \(error)")
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
                guard
                    let chainId = Bundle.main.object(forInfoDictionaryKey: "CHAIN_ID") as? String,
                    let denom = Bundle.main.object(forInfoDictionaryKey: "DENOM") as? String,
                    let rpcIp = Bundle.main.object(forInfoDictionaryKey: "RPC_IP") as? String
                else {
                    throw "some config value aren't initialized"
                }
                
                self.chainId = String(chainId.dropFirst().dropLast())
                self.denom = String(denom.dropFirst().dropLast())
                self.rpcIp = String(rpcIp.dropFirst().dropLast())
            } catch {
                fatalError("ConfigManager.Cosmos init error: \(error)")
            }
        }
    }
}
