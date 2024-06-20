import Combine
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
    
    @Published var isUserRevoking = false
    @Published var revocationChallenge = Data()
    @Published var isUserRevoked = false {
        didSet {
            UserManager.shared.isRevoked = isUserRevoked
            AppUserDefaults.shared.isUserRevoked = isUserRevoked
        }
    }
    
    @Published var isUserRegistered = false
    
    var revocationPassportPublisher =  PassthroughSubject<Passport, Error>()

    var isEligibleForReward: Bool {
        passport?.nationality == "UKR"
    }
    
    var passportCountry: Country {
        guard let passport = passport else { return .unknown }
        return Country.fromISOCode(passport.nationality)
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }

    @MainActor
    func register(
        _ downloadProgress: @escaping (String) -> Void = { _ in }
    ) async throws -> ZkProof {
        do {
            guard let passport else { throw "failed to get passport" }
            
            let registeredCircuitData = try await UserManager.shared.registerCertificate(passport)
            
            let circuitData = try await CircuitDataManager.shared.retriveCircuitData(registeredCircuitData, downloadProgress)
            
            downloadProgress("")
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            proofState = .applyingZK
            
            guard let proof = try await UserManager.shared.generateRegisterIdentityProof(passport, circuitData, registeredCircuitData) else {
                throw "failed to generate proof, invalid circuit type"
            }
            
            LoggerUtil.common.info("Passport registration proof generated")
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            proofState = .createProfile
            
            let stateKeeperContract = try StateKeeperContract()
            
            let passportInfoKey: String
            if passport.dg15.isEmpty {
                passportInfoKey = proof.pubSignals[1]
            } else {
                passportInfoKey = proof.pubSignals[0]
            }
            
            let (passportInfo, _) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
            
            let isUserRevoking = passportInfo.activeIdentity != Ethereum.ZERO_BYTES32
            
            if isUserRevoking {
                LoggerUtil.common.info("Passport is registered, revoking")
            } else {
                LoggerUtil.common.info("Passport is not registered")
            }
            
            if isUserRevoking {
                // takes last 8 bytes of activeIdentity as revocation challenge
                self.revocationChallenge = passportInfo.activeIdentity[24..<32]
                
                // This will trigger a sheet with a NFC scanning
                self.isUserRevoking = isUserRevoking
                
                var iterator = self.revocationPassportPublisher.values.makeAsyncIterator()
                
                guard let passport = try await iterator.next() else {
                    throw "failed to get passport"
                }
                
                try await UserManager.shared.revoke(passportInfo, passport)
                
                self.isUserRevoked = true
            }
            
            var certificatePubKeySize: Int
            switch registeredCircuitData {
            case .registerIdentityUniversalRSA2048:
                certificatePubKeySize = 2048
            case .registerIdentityUniversalRSA4096:
                certificatePubKeySize = 4096
            }
            
            try await UserManager.shared.register(proof, passport, certificatePubKeySize, isUserRevoking)
            
            PassportManager.shared.setPassport(passport)
            try UserManager.shared.saveRegisterZkProof(proof)
            
            self.isUserRegistered = true
            
            LoggerUtil.common.info("Passport registration succeed")
            
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            proofState = .finalizing
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            processingStatus = .success
            
            return proof
        } catch {
            processingStatus = .failure
            throw error
        }
    }
}
