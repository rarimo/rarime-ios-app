import Foundation

import Web3
import Web3ContractABI
import Web3PromiseKit

class FaceRegistryContract {
    static let eventId = "0x00479fba7a69b6aaecd137c541a6860858207877a3bf70da303a7a4bdfab466a"
    
    let web3: Web3
    
    let contract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
        
        let contractAddress = try EthereumAddress(hex: ConfigManager.shared.api.faceRegistryContractAddress, eip55: false)
                
        self.contract = try web3.eth.Contract(
            json: ContractABI.faceRegistryAbi,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func isUserRegistered(_ userAddressHex: String) async throws -> Bool {
        guard let userAddress = BigUInt(String(userAddressHex.dropFirst(2)), radix: 16) else {
            throw "Invalid user address hex"
        }
        
        let method = contract["isUserRegistered"]!(userAddress)
        
        let response = try method.call().wait()
        
        guard let result = response[""] as? Bool else {
            throw "Response does not contain bool"
        }
        
        return result
    }
    
    func getVerificationNonce(_ userAddressHex: String) async throws -> BigUInt {
        guard let userAddress = BigUInt(String(userAddressHex.dropFirst(2)), radix: 16) else {
            throw "Invalid user address hex"
        }
        
        let method = contract["getVerificationNonce"]!(userAddress)
        
        let response = try method.call().wait()
        
        guard let nonce = response[""] as? BigUInt else {
            throw "Response does not contain nonce"
        }
        
        return nonce
    }
    
    func getRule(_ userAddressHex: String) async throws -> BigUInt {
        guard let userAddress = BigUInt(String(userAddressHex.dropFirst(2)), radix: 16) else {
            throw "Invalid user address hex"
        }
        
        let method = contract["getRule"]!(userAddress)
        
        let response = try method.call().wait()
        
        guard let rule = response[""] as? BigUInt else {
            throw "Response does not contain rule"
        }
        
        return rule
    }
}
