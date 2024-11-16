import Combine
import Identity
import SwiftUI

enum PassportProofState: Int, CaseIterable {
    case readingData, applyingZK, createProfile, finalizing

    var title: LocalizedStringResource {
        switch self {
        case .readingData: "Downloading circuit data"
        case .applyingZK: "Genereting ZKP"
        case .createProfile: "Saving data"
        case .finalizing: "Finalizing"
        }
    }
}

class PassportViewModel: ObservableObject {
    @Published var passport: Passport?
    @Published var proofState: PassportProofState = .readingData
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
    
    var revocationPassportPublisher = PassthroughSubject<Passport, Error>()
    
    var passportCountry: Country {
        guard let passport = passport else { return .unknown }
        return Country.fromISOCode(passport.nationality)
    }
    
    var isEligibleForReward: Bool {
        !UNSUPPORTED_REWARD_COUNTRIES.contains(passportCountry)
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }

    @MainActor
    func register(
        _ downloadProgress: @escaping (String) -> Void = { _ in }
    ) async throws {
        do {
            guard let passport else { throw "failed to get passport" }
            
            downloadProgress("")
            
            try await Task.sleep(nanoseconds: 6 * NSEC_PER_SEC)
            proofState = .applyingZK
            
            LoggerUtil.common.info("Passport registration proof generated")
            
            try await Task.sleep(nanoseconds: 10 * NSEC_PER_SEC)
            proofState = .createProfile
            
            PassportManager.shared.setPassport(passport)
            
            isUserRegistered = true
            
            LoggerUtil.common.info("Passport registration succeed")
            
            try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
            proofState = .finalizing
            
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            processingStatus = .success
        } catch {
            processingStatus = .failure
            throw error
        }
    }
}
