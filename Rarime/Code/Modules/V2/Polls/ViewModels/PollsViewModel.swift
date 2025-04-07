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
    var isInitialPollLoaded = false

    init(poll: Poll? = nil) {
        self.selectedPoll = poll
    }
    
    var hasMorePolls: Bool {
        self.polls.count < self.lastProposalId
    }
    
    var pollRequirements: [PollRequirement] {
        guard let poll = selectedPoll,
              let passport = PassportManager.shared.passport else { return [] }
        
        guard let votingData = try? PollsService.decodeVotingData(poll) else { return [] }
        
        let decodedCountries = votingData.citizenshipWhitelist.map { Country.fromISOCode($0.serialize().ascii) }
        let decodedMinAge = votingData.birthDateUpperbound.serialize().ascii
        let decodedMaxAge = votingData.birthDateLowerbound.serialize().ascii
        let decodedGender = votingData.gender.serialize().ascii
        
        let formattedMinAge = try? DateUtil.parsePassportDate(decodedMinAge)
        let formattedMaxAge = try? DateUtil.parsePassportDate(decodedMaxAge)
        let userDateOfBirth = (try? DateUtil.parsePassportDate(passport.dateOfBirth)) ?? Date()
        
        let isNationalityEligible = decodedCountries.contains(Country.fromISOCode(passport.nationality))
        let isAgeEligible: Bool = {
            if formattedMinAge == nil && formattedMaxAge == nil {
                return true
            }

            if let formattedMinAge, let formattedMaxAge {
                 return userDateOfBirth <= formattedMinAge && userDateOfBirth >= formattedMaxAge
            }
            
            if let formattedMinAge {
                 return userDateOfBirth <= formattedMinAge
            }
            
            if let formattedMaxAge {
                 return userDateOfBirth >= formattedMaxAge
            }
            
            return false
        }()
        let isGengerEligible = {
            if decodedGender == "M" || decodedGender == "F" {
               return decodedGender == passport.gender
            }
            return false
        }()
        let countriesString = decodedCountries.map { $0.name }.joined(separator: ", ")
        let ageString: String = {
            let minYear = DateUtil.yearsBetween(from: formattedMinAge ?? Date())
            let maxYear = DateUtil.yearsBetween(from: formattedMaxAge ?? Date())
            
            if decodedMinAge != "000000" && decodedMaxAge != "000000" {
                return "\(minYear)-\(maxYear)"
            }
        
            if decodedMinAge != "000000" {
                return "\(minYear)+"
            }
        
            if decodedMaxAge != "000000" {
                return "\(maxYear) and below"
            }
        
            return "-"
        }()
        let genderString = decodedGender == "M" ? "Male only" : "Female only"
        
        var requirements: [PollRequirement] = []
        
        if !decodedCountries.isEmpty {
            requirements.append(PollRequirement(
                text: "Citizen of \(countriesString)",
                isEligible: isNationalityEligible
            ))
        }
        if decodedMinAge != "000000" || decodedMaxAge != "000000" {
            requirements.append(PollRequirement(
                text: ageString,
                isEligible: isAgeEligible
            ))
        }
        if decodedGender == "M" || decodedGender == "F" {
            requirements.append(PollRequirement(
                text: genderString,
                isEligible: isGengerEligible
            ))
        }
        
        return requirements
    }
    
    var totalParticipants: Int {
        guard let poll = selectedPoll else { return 0 }
        let questionParticipants = poll.proposalResults.map { $0.reduce(0) { $0 + Int($1) } }
        return questionParticipants.max() ?? 0
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
        
        if lastProposalId == 0 { return }
        
        let limit = min(PollsViewModel.FIRST_POLL_MAX_LIMIT, lastProposalId)
        
        let ids = (lastProposalId - limit + 1 ... lastProposalId).reversed()
        
        let multicall3Contract = try Multicall3Contract()
        
        let newPolls = try await PollsService.fetchPolls(multicall3Contract, Array(ids))
        
        self.lastProposalId = lastProposalId
        
        DispatchQueue.main.async {
            self.polls = newPolls
        }
    }
    
    func loadMorePolls() async throws {
        if isLoadingMorePolls || !isInitialPollLoaded { return }
        isLoadingMorePolls = true
        
        defer { isLoadingMorePolls = false }
        
        if !self.hasMorePolls { return }
        
        let limit: BigUInt = {
            if BigUInt(self.polls.count) + PollsViewModel.POLL_MAX_LIMIT > self.lastProposalId {
                return self.lastProposalId - BigUInt(self.polls.count)
            }
            
            return PollsViewModel.POLL_MAX_LIMIT
        }()
        
        let lastIndex = BigUInt(self.polls.last!.id)
        
        let firstIndex = lastIndex - limit
        
        let ids = (firstIndex ... lastIndex-1).reversed()
        
        let multicall3Contract = try Multicall3Contract()
        
        let newPolls = try await PollsService.fetchPolls(multicall3Contract, Array(ids))
        
        DispatchQueue.main.async {
            self.polls.append(contentsOf: newPolls)
        }
    }
    
    func vote(
        _ jwt: JWT,
        _ user: User,
        _ registerZkProof: ZkProof,
        _ passport: Passport,
        _ results: [PollResult]
    ) async throws {
        guard let poll = selectedPoll else { throw "No selected poll" }
        
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
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(user.secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportKey)
        
        let resultsJson = try JSONEncoder().encode(results)
        
        let voteProof = try await generateVoteProof(
            profile,
            passport,
            smtProofJson,
            passportKey,
            resultsJson,
            passportInfo,
            identityInfo
        )
        
        let voteProofJson = try JSONEncoder().encode(voteProof)
        let votingData = try PollsService.decodeVotingData(poll)
                
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildVoteCalldata(
            voteProofJson,
            proposalID: Int64(poll.id),
            pollResultsJSON: resultsJson,
            citizenship: passport.nationality
        )
        
        let votingRelayer = VotingRelayer(ConfigManager.shared.api.votingRelayerURL)
        let voteResponse = try await votingRelayer.vote(
            calldata.fullHex,
            poll.votingsAddresses[0].hex(eip55: false)
        )
        
        LoggerUtil.common.info("Voting \(poll.id), txHash: \(voteResponse.data.id)")
    }
    
    private func generateVoteProof(
        _ profile: IdentityProfile,
        _ passport: Passport,
        _ smtProofJson: Data,
        _ passportInfoKey: String,
        _ pollResultsJson: Data,
        _ passportInfo: PassportInfo,
        _ identityInfo: IdentityInfo
    ) async throws -> ZkProof {
        guard let poll = selectedPoll else { throw "No selected poll" }
        
        let eventData = try profile.calculateVotingEventData(pollResultsJson)
        let votingData = try PollsService.decodeVotingData(poll)
        
        let queryProofInputs = try profile.buildQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: votingData.selector.description,
            pkPassportHash: passportInfoKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: poll.eventId.description,
            eventData: eventData.fullHex,
            timestampLowerbound: "0",
            timestampUpperbound: max(
                Int(votingData.timestampUpperbound),
                Int(identityInfo.issueTimestamp + 1)
            ).description,
            identityCounterLowerbound: "0",
            identityCounterUpperbound: votingData.identityCounterUpperbound.description,
            expirationDateLowerbound: votingData.expirationDateLowerbound.serialize().fullHex,
            expirationDateUpperbound: ZERO_IN_HEX,
            birthDateLowerbound: votingData.birthDateLowerbound.serialize().fullHex,
            birthDateUpperbound: votingData.birthDateUpperbound.serialize().fullHex,
            citizenshipMask: "0"
        )
        
        let wtns = try ZKUtils.calcWtns_queryIdentity(Circuits.queryIdentityDat, queryProofInputs)
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func checkUserVote(_ nullifier: String) async throws -> Bool {
        guard let poll = selectedPoll else { throw "No selected poll" }
       
        let proposalSmtContract = try PoseidonSMT(
            contractAddress: poll.proposalSMT,
            rpcUrl: ConfigManager.shared.api.votingRpcURL
        )
        
        let proof = try await proposalSmtContract.getProof(Data(hex: nullifier))
        
        return proof.existence
    }
}
