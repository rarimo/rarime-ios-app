import Identity

import CoreData
import Foundation
import Web3
import Web3ContractABI
import Web3PromiseKit

class PollsViewModel: ObservableObject {
    private static var POLL_BASIC_REWARD: BigUInt = 50
    private static var FIRST_POLL_MAX_LIMIT: BigUInt = 20
    private static var POLL_MAX_LIMIT: BigUInt = 10
    
    @Published var selectedPoll: Poll?
    @Published var polls: [Poll] = []
    
    var lastProposalId: BigUInt = 0
    var isFetchingMore = false
    var isFirstFetchDone = false

    init(poll: Poll? = nil) {
        self.selectedPoll = poll
    }
    
    var hasMore: Bool { self.polls.count < self.lastProposalId }
    
    func loadNewPolls() async throws {
        if isFetchingMore {
            return
        }
        
        isFetchingMore = true
        defer {
            isFetchingMore = false
            isFirstFetchDone = true
        }
        
        let contract = try ProposalsStateContract()
        
        let lastProposalId = try await contract.lastProposalId()
        
        if lastProposalId == 0 {
            return
        }
        
        let limit: BigUInt = {
            if PollsViewModel.FIRST_POLL_MAX_LIMIT > lastProposalId {
                return lastProposalId
            }
            
            return PollsViewModel.FIRST_POLL_MAX_LIMIT
        }()
        
        let ids = (lastProposalId - limit + 1 ... lastProposalId).reversed()
        
        let multicall3Contract = try Multicall3Contract()
        
        let newPolls = try await fetchPolls(multicall3Contract, Array(ids))
        
        self.lastProposalId = lastProposalId
        
        DispatchQueue.main.async {
            self.polls = newPolls
        }
    }
    
    func fetchPolls(
        _ multicall3Contract: Multicall3Contract,
        _ ids: [BigUInt]
    ) async throws  -> [Poll]{
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
            if proposalInfo.status != .doNotShow {
                do {
                    let ipfsNodeURL = ConfigManager.shared.api.ipfsNodeURL
                    let proposalInfoUrl = ipfsNodeURL
                        .appendingPathComponent("ipfs")
                        .appendingPathComponent(proposalInfo.config.description)
                    
                    proposalMetadata = try await ProposalMetadata.fromURL(proposalInfoUrl)
                } catch {
                    LoggerUtil.common.warning("Can't get proposal metadata for proposalId: \(i, privacy: .public), error: \(error, privacy: .public)")
                }
            }
            
            let poll = Poll(
                id: UInt(id),
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
    
    func buildGetProposalInfoCall(_ proposalId: BigUInt) throws -> Multicall3Contract.Call3 {
        return try self.buildSimpleGetCall(proposalId, "getProposalInfo")
    }
    
    func buildGetProposalEventIdCall(_ proposalId: BigUInt) throws -> Multicall3Contract.Call3 {
        return try self.buildSimpleGetCall(proposalId, "getProposalEventId")
    }
    
    func buildSimpleGetCall(_ proposalId: BigUInt, _ callName: String) throws -> Multicall3Contract.Call3 {
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
}

struct ParticiaptionProofInputs: Codable {
    let eventIdA: String
    let eventIdB: String
    let nullifierProof: [String]
    let eventNullifiersTreeRoot: String
    let identitySK: String
    
    enum CodingKeys: String, CodingKey {
        case eventIdA = "participationEventId"
        case eventIdB = "challengedEventId"
        case nullifierProof = "nullifiersTreeSiblings"
        case eventNullifiersTreeRoot = "nullifiersTreeRoot"
        case identitySK = "skIdentity"
    }
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

