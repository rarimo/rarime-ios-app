import Foundation

import Web3
import Web3ContractABI
import Web3PromiseKit

class Ethereum {
    static let ZERO_BYTES32: Data = .init(repeating: 0, count: 32)
    
    static let TX_PULL_INTERVAL: UInt64 = NSEC_PER_SEC * 3
    
    static let TX_SUCCESS_CODE: EthereumQuantity = 1
    
    let web3: Web3
    
    init() {
        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
    }
    
    func isTxSuccessful(_ txHash: String) async throws -> Bool? {
        let txHash = try EthereumData.string(txHash)
        
        var receipt: EthereumTransactionReceiptObject
        do {
            guard let responseReceipt = try web3.eth.getTransactionReceipt(transactionHash: txHash).wait() else {
                throw "Transaction receipt is nil"
            }
            
            receipt = responseReceipt
        } catch {
            if "\(error)".contains("emptyResponse") {
                return nil
            }
            
            throw "Failed to get transaction receipt: \(error)"
        }
        
        guard let status = receipt.status else {
            return nil
        }
        
        return status == Ethereum.TX_SUCCESS_CODE
    }
    
    func waitForTxSuccess(_ txHash: String) async throws {
        while true {
            let isTxSuccessfulResult = try await isTxSuccessful(txHash)
            
            if let isTxSuccessfulResult {
                if isTxSuccessfulResult {
                    break
                }
                
                throw "Transaction failed"
            }
            
            try await Task.sleep(nanoseconds: Ethereum.TX_PULL_INTERVAL)
        }
    }
    
    static func isValidAddress(_ address: String) -> Bool {
        let pattern = "^0x[a-fA-F0-9]{40}$"
        return address.range(of: pattern, options: .regularExpression) != nil
    }
}

extension EthereumQuantity {
    var double: Double {
        let ethValue = self.quantity.eth.description

        let gweiValue = self.quantity.gwei.description
        
        let value = ethValue + "." + gweiValue.prefix(2)

        return Double(value) ?? 0
    }
}
