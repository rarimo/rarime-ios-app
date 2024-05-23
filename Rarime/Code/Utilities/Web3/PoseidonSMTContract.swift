import Foundation

import Web3
import Web3PromiseKit
import Web3ContractABI

import OSLog
import SwiftUI

class PoseidonSMT {
    let web3: Web3
    let contract: DynamicContract
    
    init(contractAddress: EthereumAddress) throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
        
        self.contract = try web3.eth.Contract(
            json: ContractABI.poseidonSMTAbiJSON,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func getProof(_ key: Data) async throws -> SMTProof {
        var index = Data()
        index.append(Data(repeating: 0, count: 32 - key.count))
        index.append(key)
        
        let response = try contract["getProof"]!(index).call().wait()
        
        guard let proof = response[""] as? [String: Any] else {
            throw "Proof is not hex"
        }
        
        guard let siblings = proof["siblings"] as? [Data] else {
            throw "Proof does not contain siblings"
        }
        
        guard let root = proof["root"] as? Data else {
            throw "Proof does not contain root"
        }
        
        guard let existence = proof["existence"] as? Bool else {
            throw "Proof does not contain existense"
        }
        
        return SMTProof(
            root: root,
            siblings: siblings,
            existence: existence
        )
    }
    
    func getRoot() async throws -> Data {
        let response = try contract["getRoot"]!().call().wait()
        
        guard let root = response[""] as? Data else {
            throw "Response does not contain root"
        }
        
        return root
    }
}
