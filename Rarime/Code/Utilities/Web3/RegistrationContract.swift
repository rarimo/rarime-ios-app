import Identity

import Web3
import Web3PromiseKit
import Web3ContractABI

import OSLog
import SwiftUI

class RegistrationContract {
    let web3: Web3
    let registrationContract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
        
        let registrationContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registerContractAddress, eip55: false)
                
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
        
        guard let proofIndex else { throw "failed to calculate proofIndex" }
        
        let response = try registrationContract["getProof"]!(proofIndex).call().wait()
        
        guard let proof = response[""] as? [String: Any] else {
            throw "Proof is not hex"
        }
        
        guard let siblings = proof["siblings"] as? [Data] else {
            throw "Proof does not contain siblings"
        }
        
        guard let root = proof["root"] as? Data else {
            throw "Proof does not contain root"
        }
        
        return SMTProof(
            root: root,
            siblings: siblings
        )
    }
    
    func getPassportInfo(_ passportKey: String) async throws -> (PassportInfo, IdentityInfo) {
        var error: NSError? = nil
        let passportKeyByts = IdentityBigIntToBytes(passportKey, &error)
        if let error {
            throw error
        }
        
        guard let passportKeyByts else { throw "Passport Key is not intialized" }
        
        let response = try registrationContract["getPassportInfo"]!(passportKeyByts).call().wait()
        
        guard let passportInfoRaw = response["passportInfo_"] as? [String: Any] else { throw "Proof is not hex" }
        
        guard let activeIdentity = passportInfoRaw["activeIdentity"] as? Data else { throw "activeIdentity is not Data" }
        guard let identityReissueCounter = passportInfoRaw["identityReissueCounter"] as? UInt64 else { throw "identityReissueCounter is not Int" }
        
        guard let identityInfoRaw = response["identityInfo_"] as? [String: Any] else { throw "Proof is not hex" }
        
        guard let activePassport = identityInfoRaw["activePassport"] as? Data else { throw "activePassport is not Data" }
        guard let issueTimestamp = identityInfoRaw["issueTimestamp"] as? UInt64 else { throw "issueTimestamp is not Int" }
        
        let passportInfo = PassportInfo(
            activeIdentity: activeIdentity,
            identityReissueCounter: identityReissueCounter
        )
        
        let identityInfo = IdentityInfo(
            activePassport: activePassport,
            issueTimestamp: issueTimestamp
        )
        
        return (passportInfo, identityInfo)
    }
}

struct SMTProof: Codable {
    let root: Data
    let siblings: [Data]
}

struct PassportInfo: Codable {
    let activeIdentity: Data
    let identityReissueCounter: UInt64
}

struct IdentityInfo: Codable {
    let activePassport: Data
    let issueTimestamp: UInt64
}