import Identity

import Web3
import Web3PromiseKit
import Web3ContractABI

import OSLog
import SwiftUI

class StateKeeperContract {
    let web3: Web3
    let contract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
        
        let contractAddress = try EthereumAddress(hex: ConfigManager.shared.api.stateKeeperContractAddress, eip55: false)
        
        self.contract = try web3.eth.Contract(
            json: ContractABI.stateKeeperAbiJSON,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func getPassportInfo(_ passportKey: String) async throws -> (PassportInfo, IdentityInfo) {
        var error: NSError? = nil
        let passportKeyByts = IdentityBigIntToBytes(passportKey, &error)
        if let error {
            throw error
        }
        
        guard var passportKeyByts else { throw "Passport Key is not intialized" }
        
        if passportKeyByts.count < 32 {
            passportKeyByts = [UInt8](repeating: 0, count: 32 - passportKeyByts.count) + passportKeyByts
        }
        
        let response = try contract["getPassportInfo"]!(passportKeyByts).call().wait()
        
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
