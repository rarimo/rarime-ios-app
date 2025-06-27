import Identity

import Web3
import Web3ContractABI
import Web3PromiseKit

import OSLog
import SwiftUI

class RegistrationContract {
    let web3: Web3
    let registrationContract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.evm.rpcURL.absoluteString)
        
        let registrationContractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.registration2Address, eip55: false)
                
        self.registrationContract = try web3.eth.Contract(
            json: ContractABI.registrationAbiJSON,
            abiKey: nil,
            address: registrationContractAddress
        )
    }
    
    func getProof(_ passportKey: String, _ identityKey: String) async throws -> SMTProof {
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportKey,
            identityKey,
            &error
        )
        if let error { throw error }
        
        guard let proofIndex else {
            throw RegistrationContractError.invalidInput("Failed to calculate proofIndex")
        }
        
        let response = try registrationContract["getProof"]!(proofIndex).call().wait()
        
        guard let proof = response[""] as? [String: Any] else {
            throw RegistrationContractError.invalidResponse("Response does not contain proof")
        }
        
        guard let siblings = proof["siblings"] as? [Data] else {
            throw RegistrationContractError.invalidResponse("Proof does not contain siblings")
        }
        
        guard let root = proof["root"] as? Data else {
            throw RegistrationContractError.invalidResponse("Proof does not contain root")
        }
        
        guard let existence = proof["existence"] as? Bool else {
            throw RegistrationContractError.invalidResponse("Proof does not contain existense")
        }
        
        return SMTProof(
            root: root,
            siblings: siblings,
            existence: existence
        )
    }
    
    func icaoMasterTreeMerkleRoot() async throws -> Data {
        let response = try registrationContract["icaoMasterTreeMerkleRoot"]!().call().wait()
        
        guard let root = response[""] as? Data else {
            throw RegistrationContractError.invalidResponse("Response does not contain root")
        }
        
        return root
    }
}

struct SMTProof: Codable {
    let root: Data
    let siblings: [Data]
    let existence: Bool
}

struct PassportInfo: Codable {
    let activeIdentity: Data
    let identityReissueCounter: UInt64
}

struct IdentityInfo: Codable {
    let activePassport: Data
    let issueTimestamp: UInt64
}

enum RegistrationContractError: Error {
    case invalidInput(String)
    case invalidResponse(String)

    var localizedDescription: String {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        }
    }
}
