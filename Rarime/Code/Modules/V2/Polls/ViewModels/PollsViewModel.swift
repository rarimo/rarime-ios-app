import Foundation
import Web3

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
}
