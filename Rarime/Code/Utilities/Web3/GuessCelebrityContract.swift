import Foundation

import Web3
import Web3ContractABI
import Web3PromiseKit

class GuessCelebrityContract {
    let web3: Web3
    
    let contract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.evm.rpcURL.absoluteString)
        
        let contractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.guessCelebrityAddress, eip55: false)
                
        self.contract = try web3.eth.Contract(
            json: ContractABI.guessCelebrityABI,
            abiKey: nil,
            address: contractAddress
        )
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
    
    func getBalance() async throws -> BigUInt {
        let method = contract["getBalance"]!()
        
        let response = try method.call().wait()
        
        guard let nonce = response[""] as? BigUInt else {
            throw "Response does not contain balance"
        }
        
        return nonce
    }
}
