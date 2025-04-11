import CoreData
import Foundation
import UIKit
import Web3
import Web3ContractABI
import Web3PromiseKit

class PollsService {
    static func fetchPolls(
        _ multicall3Contract: Multicall3Contract,
        _ ids: [BigUInt]
    ) async throws -> [Poll] {
        var calls: [Multicall3Contract.Call3] = []
        for id in ids {
            try calls.append(self.buildGetProposalInfoCall(id))
        }
        
        for id in ids {
            try calls.append(self.buildGetProposalEventIdCall(id))
        }
        
        let results = try await multicall3Contract.aggregate3(calls)
        var polls: [Poll] = []
        
        let half = results.count / 2
        for i in 0 ..< ids.count {
            let id = ids[i]
            let proposalInfo = try ProposalInfo.fromRawSolidityArray(id, results[i].returnData)
            
            let proposalEventId = try BigUInt.fromRawSolidityArray(results[half + i].returnData)
            
            var proposalMetadata = ProposalMetadata.empty()
            var pollImage: UIImage?
            
            if proposalInfo.status != .doNotShow {
                do {
                    let ipfs = IPFS()
                    proposalMetadata = try await ipfs.load(proposalInfo.config.description)
                    
                    if let imageCid = proposalMetadata.imageCid {
                        pollImage = try await ipfs.loadImage(imageCid)
                    }
                } catch {
                    LoggerUtil.common.warning("Can't get proposal metadata for proposalId: \(i, privacy: .public), error: \(error, privacy: .public)")
                }
            }
            
            let poll = Poll(
                id: UInt(id),
                image: pollImage,
                title: proposalMetadata.title,
                description: proposalMetadata.description,
                startsAt: Date(timeIntervalSince1970: Double(proposalInfo.config.startTimestamp)),
                duration: UInt(proposalInfo.config.duration),
                status: proposalInfo.status,
                questions: proposalMetadata.acceptedOptions.map { option in
                    Question(
                        title: option.title,
                        variants: option.variants,
                        isSkipable: false
                    )
                },
                votingsAddresses: proposalInfo.config.votingWhitelist,
                votingData: proposalInfo.config.votingWhitelistData,
                eventId: proposalEventId,
                proposalSMT: proposalInfo.proposalSMT,
                proposalResults: proposalInfo.votingResults
            )
            
            polls.append(poll)
        }
        
        return polls
    }
    
    static func fetchPoll(_ id: BigUInt) async throws -> Poll {
        let multicall3Contract = try Multicall3Contract()
        
        var calls: [Multicall3Contract.Call3] = []
        
        try calls.append(PollsService.buildGetProposalInfoCall(id))
        try calls.append(PollsService.buildGetProposalEventIdCall(id))
        
        let results = try await multicall3Contract.aggregate3(calls)
        let proposalInfo = try ProposalInfo.fromRawSolidityArray(id, results[0].returnData)
        let proposalEventId = try BigUInt.fromRawSolidityArray(results[1].returnData)
        var proposalMetadata = ProposalMetadata.empty()
        
        var pollImage: UIImage?
        
        if proposalInfo.status != .doNotShow {
            do {
                let ipfs = IPFS()
                proposalMetadata = try await ipfs.load(proposalInfo.config.description)
                
                if let imageCid = proposalMetadata.imageCid {
                    pollImage = try await ipfs.loadImage(imageCid)
                }
            } catch {
                LoggerUtil.common.warning("Can't get proposal metadata for proposalId: \(id, privacy: .public), error: \(error, privacy: .public)")
            }
        }
        
        return Poll(
            id: UInt(id),
            image: pollImage,
            title: proposalMetadata.title,
            description: proposalMetadata.description,
            startsAt: Date(timeIntervalSince1970: Double(proposalInfo.config.startTimestamp)),
            duration: UInt(proposalInfo.config.duration),
            status: proposalInfo.status,
            questions: proposalMetadata.acceptedOptions.map { option in
                Question(
                    title: option.title,
                    variants: option.variants,
                    isSkipable: false
                )
            },
            votingsAddresses: proposalInfo.config.votingWhitelist,
            votingData: proposalInfo.config.votingWhitelistData,
            eventId: proposalEventId,
            proposalSMT: proposalInfo.proposalSMT,
            proposalResults: proposalInfo.votingResults
        )
    }
    
    static func buildGetProposalInfoCall(_ proposalId: BigUInt) throws -> Multicall3Contract.Call3 {
        return try self.buildSimpleGetCall(proposalId, "getProposalInfo")
    }
    
    static func buildGetProposalEventIdCall(_ proposalId: BigUInt) throws -> Multicall3Contract.Call3 {
        return try self.buildSimpleGetCall(proposalId, "getProposalEventId")
    }
    
    static func buildSimpleGetCall(_ proposalId: BigUInt, _ callName: String) throws -> Multicall3Contract.Call3 {
        let calldata = try ABI.encodeFunctionCall(
            SolidityReadInvocation(
                method: SolidityConstantFunction(
                    name: callName,
                    inputs: [.init(name: "proposalId_", type: .uint256)],
                    outputs: [],
                    handler: Multicall3Contract.MockedSolHandler()
                ),
                parameters: [proposalId],
                handler: Multicall3Contract.MockedSolHandler()
            )
        )
        
        let call = try Multicall3Contract.Call3(
            target: EthereumAddress(hex: ConfigManager.shared.api.proposalsStateContractAddress, eip55: false),
            allowFailure: true,
            callData: Data(hex: calldata)
        )
        
        return call
    }
    
    static func decodeVotingData(_ poll: Poll) throws -> VotingData {
        guard let encodedVotingData = poll.votingData.abiEncode(dynamic: false) else {
            throw "Empty or nil voting data"
        }
        
        let rawDecoded = try ABIDecoder.decodeTuple(
            .tuple([
                .uint256,
                .array(type: .uint256, length: nil),
                .uint256,
                .uint256,
                .uint256,
                .uint256,
                .uint256,
                .uint256
            ]),
            from: encodedVotingData
        )
        
        guard let rawArray = rawDecoded as? [Any], rawArray.count == 8 else {
            throw "Decoding error: unexpected structure"
        }
        
        guard let selector = rawArray[0] as? BigUInt else {
            throw "Response does not contain selector"
        }
        
        guard let citizenshipWhitelist = rawArray[1] as? [BigUInt] else {
            throw "Response does not contain array of citizenship whitelist"
        }
        
        guard let timestampUpperbound = rawArray[2] as? BigUInt else {
            throw "Response does not contain timestamp upperbound"
        }
        
        guard let identityCounterUpperbound = rawArray[3] as? BigUInt else {
            throw "Response does not contain identity counter upperbound"
        }
        
        guard let gender = rawArray[4] as? BigUInt else {
            throw "Response does not contain gender"
        }
        
        guard let birthDateLowerbound = rawArray[5] as? BigUInt else {
            throw "Response does not contain birth date lowerbound"
        }
        
        guard let birthDateUpperbound = rawArray[6] as? BigUInt else {
            throw "Response does not contain birth date upperbound"
        }
        
        guard let expirationDateLowerbound = rawArray[7] as? BigUInt else {
            throw "Response does not contain expiration date lowerbound"
        }
        
        return VotingData(
            selector: selector,
            citizenshipWhitelist: citizenshipWhitelist,
            identityCreationTimestampUpperBound: timestampUpperbound,
            identityCounterUpperbound: identityCounterUpperbound,
            gender: gender,
            birthDateLowerbound: birthDateLowerbound,
            birthDateUpperbound: birthDateUpperbound,
            expirationDateLowerbound: expirationDateLowerbound
        )
    }
}

struct Poll: Identifiable {
    let id: UInt
    let image: UIImage?
    let title: String
    let description: String
    let startsAt: Date
    let duration: UInt
    let status: ProposalStatus
    let questions: [Question]
    let votingsAddresses: [EthereumAddress]
    let votingData: [Data]
    let eventId: BigUInt
    let proposalSMT: EthereumAddress
    let proposalResults: [[BigUInt]]

    var endAt: String {
        let endDate = self.startsAt.addingTimeInterval(Double(self.duration))

        if self.status == .ended {
            return String(localized: "Finished")
        }

        if self.status == .waiting {
            return String(localized: "Soon")
        }

        return DateUtil.formatDuration(UInt(endDate.timeIntervalSinceNow), precision: .minutes)
    }
}

struct VotingData: Codable {
    let selector: BigUInt
    let citizenshipWhitelist: [BigUInt]
    let identityCreationTimestampUpperBound: BigUInt
    let identityCounterUpperbound: BigUInt
    let gender: BigUInt
    let birthDateLowerbound: BigUInt
    let birthDateUpperbound: BigUInt
    let expirationDateLowerbound: BigUInt
}

struct Question {
    let title: String
    let variants: [String]
    let isSkipable: Bool
}

struct QuestionResult: Hashable {
    let question: String
    let options: [QuestionResultOption]
}

struct QuestionResultOption: Hashable {
    let answer: String
    let votes: Int
}

struct PollResult: Codable {
    let questionIndex: Int
    let answerIndex: Int?
}

struct PollRequirement: Identifiable {
    let id = UUID()
    let text: String
    let isEligible: Bool
}

extension BigUInt {
    static func fromRawSolidityArray(_ data: Data) throws -> BigUInt {
        let decoded = try ABIDecoder.decodeTuple(.uint256, from: data.fullHex)
        
        guard let value = decoded as? BigUInt else {
            throw "Response does not contain value"
        }
        
        return value
    }
}

extension ProposalInfo {
    static func fromRawSolidityArray(_ proposalId: BigUInt, _ data: Data) throws -> ProposalInfo {
        let decoded = try ABIDecoder.decodeTuple(
            .tuple([
                .address,
                .uint8,
                .tuple([
                    .uint64,
                    .uint64,
                    .uint256,
                    .array(type: .uint256, length: nil),
                    .string,
                    .array(type: .address, length: nil),
                    .array(type: .bytes(length: nil), length: nil)
                ]),
                .array(type: .array(type: .uint256, length: 8), length: nil)
            ]),
            from: data.fullHex
        )
        
        guard let raw = decoded as? [Any] else {
            throw "Decoding error"
        }
        
        guard let proposalSMT = raw[0] as? EthereumAddress else {
            throw "Response does not contain proposalSMT"
        }
        
        guard let statusRaw = raw[1] as? UInt8 else {
            throw "Response does not contain status"
        }
        
        guard let status = ProposalStatus(rawValue: statusRaw) else {
            throw "Response contains invalid status"
        }
        
        guard let configRaw = raw[2] as? [Any] else {
            throw "Response does not contain config"
        }
        
        guard let startTimestamp = configRaw[0] as? UInt64 else {
            throw "Response does not contain startTimestamp"
        }
        
        guard let duration = configRaw[1] as? UInt64 else {
            throw "Response does not contain duration"
        }
        
        guard let multichoice = configRaw[2] as? BigUInt else {
            throw "Response does not contain multichoice"
        }
        
        guard let acceptedOptions = configRaw[3] as? [BigUInt] else {
            throw "Response does not contain acceptedOptions"
        }
        
        guard let description = configRaw[4] as? String else {
            throw "Response does not contain description"
        }
        
        guard let votingWhitelist = configRaw[5] as? [EthereumAddress] else {
            throw "Response does not contain votingWhitelist"
        }
        
        guard let votingWhitelistData = configRaw[6] as? [Data] else {
            throw "Response does not contain votingWhitelistData"
        }
        
        guard let votingResults = raw[3] as? [[BigUInt]] else {
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
}
