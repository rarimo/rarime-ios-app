import Alamofire
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
    @Published var votingPollsIds: [Int] = AppUserDefaults.shared.votedPollsIds {
        didSet {
            AppUserDefaults.shared.votedPollsIds = votingPollsIds
        }
    }
    
    var lastProposalId: BigUInt = 0
    var isLoadingMorePolls = false
    var hasLoadedInitialPolls = false
    var isInitialPollLoaded = false

    init(poll: Poll? = nil) {
        self.selectedPoll = poll
    }
    
    var hasVoted: Bool {
        votingPollsIds.count > 0
    }
    
    var hasMorePolls: Bool {
        polls.count < lastProposalId
    }
    
    var pollRequirements: [PollRequirement] {
        guard let poll = selectedPoll,
              let passport = PassportManager.shared.passport else { return [] }
        
        guard let votingData = try? PollsService.decodeVotingData(poll) else { return [] }
        
        let decodedCountries = votingData.citizenshipWhitelist.map { Country.fromISOCode($0.serialize().ascii) }
        let decodedBirthDateUpperbound = votingData.birthDateUpperbound.serialize().ascii
        let decodedBirthDateLowerbound = votingData.birthDateLowerbound.serialize().ascii
        let decodedGender = votingData.gender.serialize().ascii
        let decodedExpirationDateLowerbound = votingData.expirationDateLowerbound.serialize().ascii
        
        let upperboundBirthDate = try? DateUtil.parsePassportDate(decodedBirthDateUpperbound, true)
        let lowerBoundBirthDate = try? DateUtil.parsePassportDate(decodedBirthDateLowerbound, true)
        let userBirthDate = (try? DateUtil.parsePassportDate(passport.dateOfBirth, true)) ?? Date()
        
        let expirationDateLowerbound = (try? DateUtil.parsePassportDate(decodedExpirationDateLowerbound, false)) ?? Date()
        let userExpirationDate = (try? DateUtil.parsePassportDate(passport.documentExpiryDate, false)) ?? Date()
        
        let isNationalityEligible = decodedCountries.contains(Country.fromISOCode(passport.nationality))
        let isAgeEligible: Bool = {
            if upperboundBirthDate == nil, lowerBoundBirthDate == nil {
                return true
            }

            if let upperboundBirthDate, let lowerBoundBirthDate {
                return userBirthDate <= upperboundBirthDate && userBirthDate >= lowerBoundBirthDate
            }
            
            if let upperboundBirthDate {
                return userBirthDate <= upperboundBirthDate
            }
            
            if let lowerBoundBirthDate {
                return userBirthDate >= lowerBoundBirthDate
            }
            
            return false
        }()
        let isGengerEligible = {
            if decodedGender == "M" || decodedGender == "F" {
                return decodedGender == passport.gender
            }
            return false
        }()
        let isExpirationDateEligible = decodedExpirationDateLowerbound == "000000" || userExpirationDate >= expirationDateLowerbound
        let countriesString = Set(decodedCountries.map { $0.name }).joined(separator: ", ")
        let ageString: String = {
            let minYear = DateUtil.yearsBetween(from: upperboundBirthDate ?? Date(), to: poll.startsAt)
            let maxYear = DateUtil.yearsBetween(from: lowerBoundBirthDate ?? Date(), to: poll.startsAt)
            
            if decodedBirthDateUpperbound != "000000", decodedBirthDateLowerbound != "000000" {
                return "\(minYear)-\(maxYear) years"
            }
        
            if decodedBirthDateUpperbound != "000000" {
                return "\(minYear)+"
            }
        
            if decodedBirthDateLowerbound != "000000" {
                return "\(maxYear) years or less"
            }
        
            return "-"
        }()
        let genderString = decodedGender == "M" ? "Male only" : "Female only"
        let expirationDateString = decodedExpirationDateLowerbound != "000000"
            ? "Document valid until \(DateUtil.richDateFormatter.string(from: expirationDateLowerbound ?? Date()))"
            : "-"
        
        var requirements: [PollRequirement] = []
        
        if !decodedCountries.isEmpty {
            requirements.append(PollRequirement(
                text: "Citizen of \(countriesString)",
                isEligible: isNationalityEligible
            ))
        }
        if decodedBirthDateUpperbound != "000000" || decodedBirthDateLowerbound != "000000" {
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
        if decodedExpirationDateLowerbound != "000000" {
            requirements.append(PollRequirement(
                text: expirationDateString,
                isEligible: isExpirationDateEligible
            ))
        }
        
        return requirements
    }
    
    func loadPollsByIds(_ ids: [Int]) async throws {
        if isLoadingMorePolls { return }
        
        isLoadingMorePolls = true
        defer {
            isLoadingMorePolls = false
            hasLoadedInitialPolls = true
        }
        
        let multicall3Contract = try Multicall3Contract()
        
        let newPolls = try await PollsService.fetchPolls(multicall3Contract, ids.reversed().map { BigUInt($0) })
        
        DispatchQueue.main.async {
            self.polls = newPolls
        }
    }
    
    func vote(
        _ jwt: JWT,
        _ user: User,
        _ registerZkProof: ZkProof,
        _ passport: Passport,
        _ results: [PollResult]
    ) async throws {
        guard let poll = selectedPoll else { throw PollsViewModelError.noSelectedPoll }
        
        let stateKeeperContract = try StateKeeperContract()
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.registrationSmtAddress, eip55: false)
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        guard let passportKey = UserManager.shared.getPassportKey(passport) else {
            throw UserManagerError.passportKeyNotFound
        }
        
        guard let identityKey = UserManager.shared.getIdentityKey(passport) else {
            throw UserManagerError.identityKeyNotFound
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportKey,
            identityKey,
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw UserManagerError.proofIndexNotInitialized }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(user.secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportKey)
        
        let resultsJson = try JSONEncoder().encode(results)
        
        let (voteProof, isRegisteredAfterVoting) = try await generateVoteProof(
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
            citizenship: votingData.citizenshipWhitelist.isEmpty ? Data(hex: "0x0")?.ascii : passport.nationality,
            isRegisteredAfterVoting: isRegisteredAfterVoting
        )
        
        let votingRelayer = VotingRelayer(ConfigManager.shared.freedomTool.apiURL)
        let voteResponse = try await votingRelayer.vote(
            calldata.fullHex,
            poll.votingsAddresses[0].hex(eip55: false)
        )

        LoggerUtil.common.info("Voting \(poll.id, privacy: .public), txHash: \(voteResponse.data.id, privacy: .public)")
    }
    
    private func generateVoteProof(
        _ profile: IdentityProfile,
        _ passport: Passport,
        _ smtProofJson: Data,
        _ passportInfoKey: String,
        _ pollResultsJson: Data,
        _ passportInfo: PassportInfo,
        _ identityInfo: IdentityInfo
    ) async throws -> (ZkProof, Bool) {
        guard let poll = selectedPoll else { throw PollsViewModelError.noSelectedPoll }
        
        let eventData = try profile.calculateVotingEventData(pollResultsJson)
        let votingData = try PollsService.decodeVotingData(poll)
        
        let registrationSMTAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.votingRegistrationSmtAddress, eip55: false)
        let registrationSMTContract = try PoseidonSMT(contractAddress: registrationSMTAddress, rpcUrl: ConfigManager.shared.freedomTool.rpcURL)
        
        let root_validity = try await registrationSMTContract.ROOT_VALIDITY()
        
        var identityCreationTimestampUpperBound = votingData.identityCreationTimestampUpperBound.subtracting(root_validity)
        var identityCounterUpperBound = BigUInt(UInt(UInt32.max))
        
        var isRegisteredAfterVoting = false
        if identityInfo.issueTimestamp > identityCreationTimestampUpperBound {
            if passportInfo.identityReissueCounter > votingData.identityCounterUpperbound {
                throw PollsViewModelError.notUniqueIdentity
            }
            
            identityCreationTimestampUpperBound = try BigUInt(identityInfo.issueTimestamp + 1)
            
            identityCounterUpperBound = votingData.identityCounterUpperbound
            
            isRegisteredAfterVoting = true
        }
        
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
            timestampUpperbound: identityCreationTimestampUpperBound.description,
            identityCounterLowerbound: "0",
            identityCounterUpperbound: identityCounterUpperBound.description,
            expirationDateLowerbound: votingData.expirationDateLowerbound.serialize().fullHex,
            expirationDateUpperbound: ZERO_IN_HEX,
            birthDateLowerbound: votingData.birthDateLowerbound.serialize().fullHex,
            birthDateUpperbound: votingData.birthDateUpperbound.serialize().fullHex,
            citizenshipMask: "0"
        )
        
        let wtns = try ZKUtils.calcWtns_queryIdentity(Circuits.queryIdentityDat, queryProofInputs)
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)
        
        return (ZkProof.groth(GrothZkProof(proof: proof, pubSignals: pubSignals)), isRegisteredAfterVoting)
    }
    
    func checkUserVote(_ nullifier: String) async throws -> Bool {
        guard let poll = selectedPoll else { throw PollsViewModelError.noSelectedPoll }
       
        let proposalSmtContract = try PoseidonSMT(
            contractAddress: poll.proposalSMT,
            rpcUrl: ConfigManager.shared.freedomTool.rpcURL
        )
        
        let proof = try await proposalSmtContract.getProof(Data(hex: nullifier))
        
        return proof.existence
    }
    
    func reset() {
        AppUserDefaults.shared.votedPollsIds = []
    }
}

enum PollsViewModelError: Error {
    case noSelectedPoll
    case notUniqueIdentity
    
    var localizedDescription: String {
        switch self {
        case .noSelectedPoll:
            return "No selected poll"
        case .notUniqueIdentity:
            return "Your identity can not be uniquely verified for voting"
        }
    }
}
