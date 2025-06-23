import Alamofire

import Web3
import Web3PromiseKit
import Web3ContractABI

import SwiftUI

class ProposalsStateContract {
    let web3: Web3
    
    let contract: DynamicContract
    
    init() throws {
        self.web3 = Web3(rpcURL: ConfigManager.shared.freedomTool.rpcURL.absoluteString)
        
        let contractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.proposalsStateAddress, eip55: false)
                
        self.contract = try web3.eth.Contract(
            json: ContractABI.proposalsStateAbiJSON,
            abiKey: nil,
            address: contractAddress
        )
    }
    
    func getVotings() async throws -> [VotingMetadata] {
        let method = contract["getVotings"]!()
        
        let response = try method.call().wait()
        
        guard let keys = response["keys_"] as? [String] else {
            throw "Response does not contain keys"
        }
        
        guard let addresses = response["values_"] as? [EthereumAddress] else {
            throw "Response does not contain addresses"
        }
        
        var result: [VotingMetadata] = []
        for (key, address) in zip(keys, addresses) {
            result.append(VotingMetadata(key: key, address: address))
        }
        
        return result
    }
    
    func lastProposalId() async throws -> BigUInt {
        let method = contract["lastProposalId"]!()
        
        let response = try method.call().wait()
        
        guard let lastProposalId = response[""] as? BigUInt else {
            throw "Response does not contain lastProposalId"
        }
        
        return lastProposalId
    }
    
    func getProposalInfo(_ proposalId: BigUInt) async throws -> ProposalInfo {
        let method = contract["getProposalInfo"]!(proposalId)
        
        let response = try method.call().wait()
        
        guard let raw = response["info_"] as? [String: Any] else {
            throw "Response does not contain info"
        }
        
        guard let proposalSMT = raw["proposalSMT"] as? EthereumAddress else {
            throw "Response does not contain proposalSMT"
        }
        
        guard let statusRaw = raw["status"] as? UInt8 else {
            throw "Response does not contain status"
        }
        
        guard let status = ProposalStatus(rawValue: statusRaw) else {
            throw "Response contains invalid status"
        }
        
        guard let configRaw = raw["config"] as? [String: Any] else {
            throw "Response does not contain config"
        }
        
        guard let startTimestamp = configRaw["startTimestamp"] as? UInt64 else {
            throw "Response does not contain startTimestamp"
        }
        
        guard let duration = configRaw["duration"] as? UInt64 else {
            throw "Response does not contain duration"
        }
        
        guard let multichoice = configRaw["multichoice"] as? BigUInt else {
            throw "Response does not contain multichoice"
        }
        
        guard let acceptedOptions = configRaw["acceptedOptions"] as? [BigUInt] else {
            throw "Response does not contain acceptedOptions"
        }
        
        guard let description = configRaw["description"] as? String else {
            throw "Response does not contain description"
        }
        
        guard let votingWhitelist = configRaw["votingWhitelist"] as? [EthereumAddress] else {
            throw "Response does not contain votingWhitelist"
        }
        
        guard let votingWhitelistData = configRaw["votingWhitelistData"] as? [Data] else {
            throw "Response does not contain votingWhitelistData"
        }
        
        guard let votingResults = raw["votingResults"] as? [[BigUInt]] else {
            throw "Response does not contain votingResults"
        }
        
        return ProposalInfo(
            id: proposalId,
            proposalSMT: proposalSMT,
            status: status,
            config: ProposalConfig(
                startTimestamp: startTimestamp,
                duration: duration,
                multichoice: multichoice,
                acceptedOptions: acceptedOptions,
                description: description,
                votingWhitelist: votingWhitelist,
                votingWhitelistData: votingWhitelistData
            ),
            votingResults: votingResults
        )
    }
    
    func getProposalEventId(_ proposalId: BigUInt) async throws -> BigUInt {
        let method = contract["getProposalEventId"]!(proposalId)
        
        let response = try method.call().wait()
        
        guard let eventId = response[""] as? BigUInt else {
            throw  "Response does not contain eventId"
        }
        
        return eventId
    }
}

struct VotingMetadata {
    let key: String
    let address: EthereumAddress
}

enum ProposalStatus: UInt8, Codable {
    case none, waiting, started, ended, doNotShow
}

struct ProposalConfig: Codable {
    let startTimestamp: UInt64
    let duration: UInt64
    let multichoice: BigUInt
    let acceptedOptions: [BigUInt]
    let description: String
    let votingWhitelist: [EthereumAddress]
    let votingWhitelistData: [Data]
}

struct ProposalInfo: Codable {
    let id: BigUInt
    let proposalSMT: EthereumAddress
    let status: ProposalStatus
    let config: ProposalConfig
    let votingResults: [[BigUInt]]
}

struct ProposalMetadata: Codable {
    let title, description: String
    let imageCid: String?
    let acceptedOptions: [ProposalMetadataAcceptedOption]
    
    static func empty() -> Self {
        return Self(
            title: "",
            description: "",
            imageCid: nil,
            acceptedOptions: []
        )
    }
}

struct ProposalMetadataAcceptedOption: Codable {
    let title: String
    let description: String?
    let variants: [String]
}
