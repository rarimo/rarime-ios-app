import SwiftUI

enum PassportProofState: Int, CaseIterable {
    // TODO: Implement proof states
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

    var isEligibleForReward: Bool {
        passport?.nationality == "UKR"
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }

    @MainActor
    func generateProof() async {
        do {
            // TODO: Generate proof
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            proofState = .applyingZK
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            proofState = .createProfile
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            proofState = .finalizing
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            processingStatus = .success
        } catch {
            processingStatus = .failure
            LoggerUtil.passport.error("Error while generating proof: \(error)")
        }
    }
}
