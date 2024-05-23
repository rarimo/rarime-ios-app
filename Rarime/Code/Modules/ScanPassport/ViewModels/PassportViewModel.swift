import SwiftUI

enum PassportProofState: Int, CaseIterable {
    case readingData, applyingZK, createProfile, finalizing

    var title: LocalizedStringResource {
        switch self {
        case .readingData: "Reading Data"
        case .applyingZK: "Applying Zero Knowledge"
        case .createProfile: "Creating a confidential profile"
        case .finalizing: "Finalizing"
        }
    }
}

class PassportViewModel: ObservableObject {
    @Published var passport: Passport?
    @Published var proofState: PassportProofState = .readingData
    @Published var processingStatus: ProcessingStatus = .processing
    
    @Published var isAirdropClaimed = false

    var isEligibleForReward: Bool {
        passport?.nationality == "UKR"
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }

    @MainActor
    func register() async throws -> ZkProof {
        do {
            guard let passport else { throw "failed to get passport" }
            
            try await UserManager.shared.registerCertificate(passport)
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            proofState = .applyingZK
            
            guard let proof = try await UserManager.shared.generateRegisterIdentityProof(passport) else {
                throw "failed to generate proof, invalid circuit type"
            }
            
            LoggerUtil.common.info("Passport registration proof generated")
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            proofState = .createProfile
            
            try await UserManager.shared.register(proof, passport)
            
            LoggerUtil.common.info("Passport registration succeed")
            
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            proofState = .finalizing
            
            isAirdropClaimed = try await UserManager.shared.isAirdropClaimed()
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            processingStatus = .success
            
            return proof
        } catch {
            processingStatus = .failure
            throw error
        }
    }
}
