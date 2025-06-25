import Identity

import Web3
import Web3ContractABI
import Web3PromiseKit

import Foundation
import Semaphore

class Multicall3Contract {
    let web3: Web3
    
    let contract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.freedomTool.rpcURL.absoluteString)
        
        let contractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.multicall3Address, eip55: false)
        
        self.contract = try web3.eth.Contract(
            json: ContractABI.multicall3AbiJSON,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func aggregate3(_ calls: [Call3]) async throws -> [Result] {
        let callsJson = try JSONEncoder().encode(calls)
        var error: NSError?
        
        let calldata = IdentityCalculateAggregate3Calldata(callsJson, &error)
        
        if let error {
            throw error
        }
        
        let call = try EthereumCall(to: contract.address!, data: EthereumData(calldata!))
        
        var result: [String: Any]?
        var callError: Error?
        let semaphore = AsyncSemaphore(value: 0)
        contract.call(
            call,
            outputs: [
                .init(
                    name: "returnData",
                    type: .array(
                        type: .tuple([.bool, .bytes(length: nil)]),
                        length: nil
                    )
                )
            ]
        ) { _result, error in
            result = _result
            callError = error
            
            semaphore.signal()
        }
        
        await semaphore.wait()
        
        if let callError {
            throw callError
        }
        
        guard let rawArray = result!["returnData"] as? [Any] else {
            throw Multicall3ContractError.invalidResponse("Response does not contain returnData")
        }
        
        var results: [Result] = []
        for raw in rawArray {
            guard let dict = raw as? [Any] else {
                throw Multicall3ContractError.invalidResponse("Response does not contain returnData")
            }
            
            guard let success = dict[0] as? Bool else {
                throw Multicall3ContractError.invalidResponse("Response does not contain success")
            }
            
            guard let returnData = dict[1] as? Data else {
                throw Multicall3ContractError.invalidResponse("Response contains invalid status")
            }
            
            results.append(Result(success: success, returnData: returnData))
        }
        
        return results
    }
}

extension Multicall3Contract {
    struct Call3: ABIEncodable, Codable {
        func abiEncode(dynamic: Bool) -> String? {
            let result = try? ABI.encodeParameter(.tuple(.address(target), .bool(allowFailure), .bytes(callData)))
            
            return result.map { value in
                String(value.dropFirst(2))
            }
        }
        
        let target: EthereumAddress
        let allowFailure: Bool
        let callData: Data
    }
    
    struct Result {
        let success: Bool
        let returnData: Data
    }
    
    class MockedSolHandler: SolidityFunctionHandler {
        var address: EthereumAddress?
        
        func call(_ call: EthereumCall, outputs: [SolidityFunctionParameter], block: EthereumQuantityTag, completion: @escaping ([String: Any]?, (any Error)?) -> Void) {}
        
        func send(_ transaction: EthereumTransaction, completion: @escaping (EthereumData?, (any Error)?) -> Void) {}
        
        func estimateGas(_ call: EthereumCall, completion: @escaping (EthereumQuantity?, (any Error)?) -> Void) {}
    }
}

enum Multicall3ContractError: Error {
    case invalidResponse(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse(let message):
            return "Invalid response - \(message)"
        }
    }
}
