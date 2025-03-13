import Foundation
import Identity
import Web3
import Web3ContractABI
import Web3PromiseKit

private let ZERO_IN_HEX: String = "0x303030303030"

class PollsViewModel: ObservableObject {
    private static var FIRST_POLL_MAX_LIMIT: BigUInt = 20
    private static var POLL_MAX_LIMIT: BigUInt = 10
    
    @Published var selectedPoll: Poll?
    @Published var polls: [Poll] = []
    
    var lastProposalId: BigUInt = 0
    var isLoadingMorePolls = false
    var hasLoadedInitialPolls = false

    init(poll: Poll? = nil) {
        self.selectedPoll = poll
    }
    
    var hasMorePolls: Bool {
        self.polls.count < self.lastProposalId
    }
    
    var totalParticipants: Int {
        guard let poll = selectedPoll else { return 0 }
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
    var decodedVotingData: VotingData? {
        guard let poll = selectedPoll else { return nil }
        return try? PollsService.decodeVotingData(poll)
    }
    
    func loadNewPolls() async throws {
        if isLoadingMorePolls {
            return
        }
        
        isLoadingMorePolls = true
        defer {
            isLoadingMorePolls = false
            hasLoadedInitialPolls = true
        }
        
        let contract = try ProposalsStateContract()
        
        let lastProposalId = try await contract.lastProposalId()
        
        if lastProposalId == 0 {
            return
        }
        
        let limit = min(PollsViewModel.FIRST_POLL_MAX_LIMIT, lastProposalId)
        
        let ids = (lastProposalId - limit + 1 ... lastProposalId).reversed()
        
        let multicall3Contract = try Multicall3Contract()
        
        let newPolls = try await PollsService.fetchPolls(multicall3Contract, Array(ids))
        
        self.lastProposalId = lastProposalId
        
        DispatchQueue.main.async {
            self.polls = newPolls
        }
    }
    
    func checkIfUserVoted(_ nullifier: String) async throws -> Bool {
        guard let poll = selectedPoll else { throw "No selected poll" }
       
        let proposalSmtContract = try PoseidonSMT(contractAddress: poll.proposalSMT)
        let proof = try await proposalSmtContract.getProof(Data(hex: nullifier))
        
        return proof.existence
    }
    
    func vote(
        _ jwt: JWT,
        _ user: User,
        _ registerZkProof: ZkProof,
        _ passport: Passport,
        _ results: [PollResult]
    ) async throws {
        let stateKeeperContract = try StateKeeperContract()
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        guard let passportKey = UserManager.shared.getPassportKey(passport) else {
            throw "failed to get passport key"
        }
        
        guard let identityKey = UserManager.shared.getIdentityKey(passport) else {
            throw "failed to get identity key"
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportKey,
            identityKey,
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "Proof index is not initialized" }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(user.secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportKey)
        
        let resultsJson = try JSONEncoder().encode(results)
        
        let voteProof = try await generateVoteProof(
            stateKeeperContract,
            profile,
            passport,
            smtProof,
            passportKey,
            resultsJson,
            passportInfo,
            identityInfo
        )
        
        print("vote proof", voteProof)
        
        let voteProofJson = try JSONEncoder().encode(voteProof)
        
        guard let poll = selectedPoll else { throw "No selected poll" }
        let votingData = try PollsService.decodeVotingData(poll)
                
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildVoteCalldata(
            voteProofJson,
            proposalID: Int64(poll.id),
            pollResultsJSON: resultsJson,
            citizenship: votingData.citizenshipMask[0].description
        )
        
        print("proposal Id", Int64(poll.id))
        print("voting adresses", poll.votingsAddresses[0].hex(eip55: false))
        print("calldata", calldata.fullHex)
        
        let votingRelayer = VotingRelayer(ConfigManager.shared.api.votingRelayerURL)
        
        let voteResponse = try await votingRelayer.vote(
            calldata.fullHex,
            poll.votingsAddresses[0].hex(eip55: false)
        )
        
        
        
        LoggerUtil.common.info("Voting \(poll.id), txHash: \(voteResponse.data.id)")
    }
    
    private func generateVoteProof(
        _ stateKeeperContract: StateKeeperContract,
        _ profile: IdentityProfile,
        _ passport: Passport,
        _ smtProof: SMTProof,
        _ passportInfoKey: String,
        _ pollResultsJson: Data,
        _ passportInfo: PassportInfo,
        _ identityInfo: IdentityInfo
    ) async throws -> ZkProof {
        guard let poll = selectedPoll else { throw "No selected poll" }
        
        let eventData = try profile.calculateVotingEventData(pollResultsJson)
        guard let encodedEventId = poll.eventId.abiEncode(dynamic: false) else {
            throw "Decoding event id error"
        }
    
        let votingData = try PollsService.decodeVotingData(poll)
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let queryProofInputs = try profile.buildQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: "6657",
            pkPassportHash: passportInfoKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: "0x" + encodedEventId,
            eventData: eventData.fullHex,
            timestampLowerbound: "0",
            timestampUpperbound: max(
                Int(votingData.timestampUpperbound),
                Int(identityInfo.issueTimestamp + 1)
            ).description,
            identityCounterLowerbound: "0",
            identityCounterUpperbound: (passportInfo.identityReissueCounter + 1).description,
            expirationDateLowerbound: votingData.expirationDateLowerbound.toHex(),
            expirationDateUpperbound: ZERO_IN_HEX,
            birthDateLowerbound: ZERO_IN_HEX,
            birthDateUpperbound: votingData.birthDateUpperbound.toHex(),
            citizenshipMask: votingData.citizenshipMask[0].toHex()
        )
        
        let wtns = try ZKUtils.calcWtns_queryIdentity(Circuits.queryIdentityDat, queryProofInputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
}
