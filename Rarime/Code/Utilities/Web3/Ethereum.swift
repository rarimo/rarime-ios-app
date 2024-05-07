import Foundation

import Web3
import Web3PromiseKit
import Web3ContractABI

class Ethereum {
    static let TX_SUCCESS_CODE: EthereumQuantity = 1
    
    let web3: Web3
    
    init() {
        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
    }
    
    func isTxSuccessful(_ txHash: String) async throws -> Bool {
        let txHash = try EthereumData.string(txHash)
        
        guard let receipt = try web3.eth.getTransactionReceipt(transactionHash: txHash).wait() else {
            throw "Transaction receipt is nil"
        }
        
        guard let status = receipt.status else {
            return false
        }
        
        return status == Ethereum.TX_SUCCESS_CODE
    }
    
    func waitForTxSuccess(_ txHash: String) async throws {
        while true {
            if try await isTxSuccessful(txHash) {
                return
            }
            
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
        }
    }
}
