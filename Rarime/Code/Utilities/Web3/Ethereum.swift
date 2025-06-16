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
    
    static func formatAddress(_ address: String) -> String {
        return isValidAddress(address) ? "\(address.prefix(6))...\(address.suffix(4))" : "–"
    }
}

extension Web3.Eth {
    func getBalanceAsync(address: EthereumAddress, block: EthereumQuantityTag) async throws -> EthereumQuantity {
        try await withCheckedThrowingContinuation { continuation in
            firstly {
                getBalance(address: address, block: block)
            }.done { qty in
                continuation.resume(returning: qty)
            }.catch { err in
                continuation.resume(throwing: err)
            }
        }
    }
}

let ONE_ETHER = Decimal(sign: .plus, exponent: 18, significand: Decimal(1))

extension EthereumQuantity {
    var decimal: Decimal {
        let weiDecimal = Decimal(string: quantity.description) ?? .zero
        return weiDecimal / ONE_ETHER
    }
    
    init(decimal: Decimal) {
        let weiString = NSDecimalNumber(decimal: decimal * ONE_ETHER).stringValue
        self.init(quantity: BigUInt(weiString) ?? BigUInt(0))
    }
}

extension EthereumQuantity {
    func format(
        minFractionDigits: Int = 2,
        maxFractionDigits: Int = 6
    ) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = minFractionDigits
        fmt.maximumFractionDigits = maxFractionDigits

        return fmt.string(from: NSDecimalNumber(decimal: decimal)) ?? "–"
    }
}
