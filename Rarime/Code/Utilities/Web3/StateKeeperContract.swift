import Identity

import Web3
import Web3ContractABI
import Web3PromiseKit

import OSLog
import SwiftUI

class StateKeeperContract {
    let web3: Web3
    let contract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.evm.rpcURL.absoluteString)
        
        let contractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.stateKeeperAddress, eip55: false)
        
        self.contract = try web3.eth.Contract(
            json: ContractABI.stateKeeperAbiJSON,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func getPassportInfo(_ passportKey: String) async throws -> (PassportInfo, IdentityInfo) {
        var error: NSError?
        let passportKeyByts = IdentityBigIntToBytes(passportKey, &error)
        if let error {
            throw error
        }
        
        guard var passportKeyByts else { throw StateKeeperContractError.invalidInput("Invalid passport key format") }
        
        if passportKeyByts.count < 32 {
            passportKeyByts = [UInt8](repeating: 0, count: 32 - passportKeyByts.count) + passportKeyByts
        }
        
        let response = try contract["getPassportInfo"]!(passportKeyByts).call().wait()
        
        guard let passportInfoRaw = response["passportInfo_"] as? [String: Any] else {
            throw StateKeeperContractError.invalidResponse("passportInfo_ is not a dictionary")
        }
        
        guard let activeIdentity = passportInfoRaw["activeIdentity"] as? Data else {
            throw StateKeeperContractError.invalidResponse("activeIdentity is not Data")
        }
        guard let identityReissueCounter = passportInfoRaw["identityReissueCounter"] as? UInt64 else {
            throw StateKeeperContractError.invalidResponse("identityReissueCounter is not Int")
        }
        
        guard let identityInfoRaw = response["identityInfo_"] as? [String: Any] else {
            throw StateKeeperContractError.invalidResponse("identityInfo_ is not a dictionary")
        }
        
        guard let activePassport = identityInfoRaw["activePassport"] as? Data else {
            throw StateKeeperContractError.invalidResponse("activePassport is not Data")
        }
        guard let issueTimestamp = identityInfoRaw["issueTimestamp"] as? UInt64 else {
            throw StateKeeperContractError.invalidResponse("issueTimestamp is not Int")
        }
        
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

enum StateKeeperContractError: Error {
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
