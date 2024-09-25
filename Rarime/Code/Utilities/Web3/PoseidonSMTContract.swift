import Foundation

import Web3
import Web3PromiseKit
import Web3ContractABI

import OSLog
import SwiftUI

class PoseidonSMT {
    static let revokedValue = Data(hex: "f762965bdb8dff81b8c1397e6074e78216cd3eefe37835af6bd83d5348ea57f3")!
    
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
    
    func getNodeByKey(_ key: Data) async throws -> SMTNode {
        let index = Data(repeating: 0, count: 32 - key.count) + key
        
        let response = try contract["getNodeByKey"]!(index).call().wait()
        
        guard let proof = response[""] as? [String: Any] else {
            throw "Proof is not hex"
        }
        
        guard let nodeType = proof["nodeType"] as? UInt8 else {
            throw "Proof does not contain nodeType"
        }
        
        guard let childLeft = proof["childLeft"] as? UInt64 else {
            throw "Proof does not contain childLeft"
        }
        
        guard let childRight = proof["childRight"] as? UInt64 else {
            throw "Proof does not contain childRight"
        }
        
        guard let nodeHash = proof["nodeHash"] as? Data else {
            throw "Proof does not contain nodeHash"
        }
        
        guard let key = proof["key"] as? Data else {
            throw "Proof does not contain key"
        }
        
        guard let value = proof["value"] as? Data else {
            throw "Proof does not contain value"
        }
        
        return SMTNode(
            nodeType: SMTNodeType(rawValue: Int(nodeType))!,
            childLeft: childLeft,
            childRight: childRight,
            nodeHash: nodeHash,
            key: key,
            value: value
        )
    }
}

enum SMTNodeType: Int, Codable {
    case empty
    case leaf
    case middle
}

struct SMTNode: Codable {
    let nodeType: SMTNodeType
    let childLeft: UInt64
    let childRight: UInt64
    let nodeHash: Data
    let key: Data
    let value: Data
}
