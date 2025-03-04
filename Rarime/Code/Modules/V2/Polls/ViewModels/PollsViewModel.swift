import Foundation
import Web3
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
    var isFetchingMore = false
    var isFirstFetchDone = false

    init(poll: Poll? = nil) {
        self.selectedPoll = poll
    }
    
    var hasMorePolls: Bool {
        self.polls.count < self.lastProposalId
    }
    
    var pollTotalParticipants: Int {
        guard let poll = selectedPoll else { return 0 }
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
    }
    
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
        
        let newPolls = try await PollsService.fetchPolls(multicall3Contract, Array(ids))
        
        self.lastProposalId = lastProposalId
        
        DispatchQueue.main.async {
            self.polls = newPolls
        }
    }
    
    func checkIfUserVoted(_ nullifier: Data) async throws -> Bool {
        let proposalSmtContract = try PoseidonSMT(contractAddress: self.selectedPoll!.proposalSMT)
        let proof = try await proposalSmtContract.getProof(nullifier)
        
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
        let passportInfoKey = registerZkProof.pubSignals[1]
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportInfoKey,
            registerZkProof.pubSignals[3],
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "Proof index is not initialized" }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(user.secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
        
        let resultsJson = try JSONEncoder().encode(results)
        
        let voteProof = try await generateVoteProof(
            stateKeeperContract,
            profile,
            passport,
            smtProof,
            passportInfoKey,
            resultsJson,
            passportInfo,
            identityInfo
        )
        
        let voteProofJson = try JSONEncoder().encode(voteProof)
        let votingData = try PollsService.decodeVotingData(selectedPoll!)
                
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildVoteCalldata(
            voteProofJson,
            proposalID: Int64(self.selectedPoll!.id),
            pollResultsJSON: resultsJson,
            citizenship: votingData.citizenshipMask.description
        )
        
        let votingRelayer = VotingRelayer(ConfigManager.shared.api.votingRelayerURL)
        
        let voteResponse = try await votingRelayer.vote(
            String(self.selectedPoll!.id),
            calldata.fullHex
        )
        
        LoggerUtil.common.info("Voting \(self.selectedPoll!.id), txHash: \(voteResponse.data.id)")
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
        let eventData = try profile.calculateVotingEventData(pollResultsJson)
        
        guard let encodedEventId = selectedPoll!.eventId.abiEncode(dynamic: false) else {
            throw "Decoding event id error"
        }
    
        let votingData = try PollsService.decodeVotingData(selectedPoll!)
        
        let queryProofInputs = try profile.buildQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: JSONEncoder().encode(smtProof),
            selector: "6657",
            pkPassportHash: passportInfoKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: "0x" + encodedEventId,
            eventData: eventData.description, // check if is working after voting relayer impl
            timestampLowerbound: "0",
            timestampUpperbound: votingData.timestampUpperbound.description,
            identityCounterLowerbound: "0",
            identityCounterUpperbound: votingData.identityCounterUpperbound.description,
            expirationDateLowerbound: ZERO_IN_HEX,
            expirationDateUpperbound: votingData.expirationDateLowerbound.description,
            birthDateLowerbound: ZERO_IN_HEX,
            birthDateUpperbound: votingData.birthDateUpperbound.description,
            citizenshipMask: votingData.citizenshipMask[0].description
        )
        
        let wtns = try ZKUtils.calcWtnsQueryIdentity(queryProofInputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
}
