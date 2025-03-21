import Combine
import Identity
import SwiftUI
import Web3

enum PassportProofState: Int, CaseIterable {
    case downloadingData, applyingZK, createProfile, finalizing

    var title: LocalizedStringResource {
        switch self {
        case .downloadingData: "Downloading data"
        case .applyingZK: "Applying Zero Knowledge"
        case .createProfile: "Creating a confidential profile"
        case .finalizing: "Finalizing"
        }
    }
}

class PassportViewModel: ObservableObject {
    @Published var mrzKey: String?
    @Published var passport: Passport?
    @Published var proofState: PassportProofState = .downloadingData
    @Published var processingStatus: ProcessingStatus = .processing
    
    @Published var isAirdropClaimed = false
    
    @Published var isUserRevoking = false
    @Published var revocationChallenge = Data()
    @Published var isUserRevoked = false {
        didSet {
            UserManager.shared.isRevoked = isUserRevoked
            AppUserDefaults.shared.isUserRevoked = isUserRevoked
        }
    }
    
    @Published var isUserRegistered = false
    
    @Published var isUSA = false
    
    var revocationPassportPublisher = PassthroughSubject<Passport, Error>()
    
    var passportCountry: Country {
        guard let passport = passport else { return .unknown }
        return Country.fromISOCode(passport.nationality)
    }
    
    var isEligibleForReward: Bool {
        !UNSUPPORTED_REWARD_COUNTRIES.contains(passportCountry)
    }
    
    func setMrzKey(_ value: String) {
        mrzKey = value
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }

    @MainActor
    func register(
        _ downloadProgress: @escaping (String) -> Void = { _ in }
    ) async throws {
        guard let passport else { throw "failed to get passport" }
        guard let user = UserManager.shared.user else { throw "failed to get user" }
        
        try await UserManager.shared.registerCertificate(passport)
            
        let registerIdentityInputs = try await CircuitBuilderManager.shared.noirRegisterIdentityCircuit.buildInputs(user.secretKey, passport)
            
        proofState = .applyingZK
            
        let proof = try ZKUtils.generateNoirProof(registerIdentityInputs)
        
        UIPasteboard.general.string = proof.fullHex
        
        throw "a"
            
        LoggerUtil.common.info("Passport registration proof generated")
            
        try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        proofState = .createProfile
            
//        try await UserManager.shared.register(proof, passport, isUserRevoking, registerIdentityCircuitName)
            
        PassportManager.shared.setPassport(passport)
            
        isUserRegistered = true
            
        LoggerUtil.common.info("Passport registration succeed")
            
        try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        proofState = .finalizing
            
        try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
        processingStatus = .success
    }
}
