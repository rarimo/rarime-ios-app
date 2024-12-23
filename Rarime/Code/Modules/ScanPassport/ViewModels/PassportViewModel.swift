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
    ) async throws -> ZkProof {
        var isCriticalRegistrationProcessInProgress = true
        
        do {
            guard let passport else { throw "failed to get passport" }
            guard let user = UserManager.shared.user else { throw "failed to get user" }
            
            try await UserManager.shared.registerCertificate(passport)
            
            guard let registerIdentityCircuitType = try passport.getRegisterIdentityCircuitType() else {
                throw "failed to get register identity circuit"
            }
            
            guard let registerIdentityCircuitName = registerIdentityCircuitType.buildName() else {
                throw "failed to get register identity circuit name"
            }
            
            LoggerUtil.common.info("Registering passport with circuit: \(registerIdentityCircuitName)")
            
            guard let registeredCircuitData = RegisteredCircuitData(rawValue: registerIdentityCircuitName) else {
                throw "failed to get registered circuit data, circuit does not exist"
            }
            
            isCriticalRegistrationProcessInProgress = false
            
            let circuitData = try await CircuitDataManager.shared.retriveCircuitData(registeredCircuitData, downloadProgress)
            
            isCriticalRegistrationProcessInProgress = true
            
            proofState = .applyingZK
            
            let registerIdentityInputs = try await CircuitBuilderManager.shared.registerIdentityCircuit.buildInputs(
                user.secretKey,
                passport,
                registerIdentityCircuitType
            )
            
            let proof = try UserManager.shared.generateRegisterIdentityProof(registerIdentityInputs.json, circuitData, registeredCircuitData)
            
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
            
            let profile = try IdentityProfile().newProfile(UserManager.shared.user?.secretKey)
            
            let currentIdentityKey = try profile.getPublicKeyHash()
            
            let (passportInfo, _) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
            
            if passportInfo.activeIdentity == currentIdentityKey {
                LoggerUtil.common.info("Passport is already registered")
                
                if passportInfo.identityReissueCounter > 0 {
                    isUserRevoked = true
                }
                
                PassportManager.shared.setPassport(passport)
                try UserManager.shared.saveRegisterZkProof(proof)
                
                isUserRegistered = true
                proofState = .finalizing
                
                processingStatus = .success
                
                return proof
            }
            
            let isUserRevoking = passportInfo.activeIdentity != Ethereum.ZERO_BYTES32
            let isUserAlreadyRevoked = passportInfo.activeIdentity == PoseidonSMT.revokedValue
            
            if isUserRevoking {
                if isUserAlreadyRevoked {
                    LoggerUtil.common.info("Passport is already revoked")
                } else {
                    LoggerUtil.common.info("Passport is revoking")
                }
            } else {
                LoggerUtil.common.info("Passport is not registered")
            }
            
            if isUserRevoking && !isUserAlreadyRevoked {
                // takes last 8 bytes of activeIdentity as revocation challenge
                revocationChallenge = passportInfo.activeIdentity[24 ..< 32]
                
                // This will trigger a sheet with a NFC scanning
                self.isUserRevoking = isUserRevoking
                
                var iterator = revocationPassportPublisher.values.makeAsyncIterator()
                
                isCriticalRegistrationProcessInProgress = false
                
                guard let passport = try await iterator.next() else {
                    throw "failed to get passport"
                }
                
                isCriticalRegistrationProcessInProgress = true
                
                try await UserManager.shared.revoke(passportInfo, passport)
            }
            
            if isUserRevoking { isUserRevoked = true }
            
            try await UserManager.shared.register(proof, passport, isUserRevoking, registerIdentityCircuitName)
            
            PassportManager.shared.setPassport(passport)
            try UserManager.shared.saveRegisterZkProof(proof)
            
            try await NotificationManager.shared.subscribe(toTopic: ConfigManager.shared.general.claimableNotificationTopic)
            
            isUserRegistered = true
            
            LoggerUtil.common.info("Passport registration succeed")
            
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            proofState = .finalizing
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            processingStatus = .success
            
            return proof
        } catch {
            if !isCriticalRegistrationProcessInProgress {
                processingStatus = .failure
                
                throw error
            }
            
            do {
                return try await lightRegister()
            } catch {
                processingStatus = .failure
                
                throw error
            }
        }
    }
    
    @MainActor
    func lightRegister() async throws -> ZkProof {
        do {
            guard let user = UserManager.shared.user else { throw "failed to get user" }
            guard let passport else { throw "failed to get passport" }

            let registerIdentityLightCircuitName = try passport.getRegisterIdentityLightCircuitName()
            
            LoggerUtil.common.info("Registering passport with light circuit: \(registerIdentityLightCircuitName)")
            
            guard let registeredCircuitData = RegisteredCircuitData(rawValue: registerIdentityLightCircuitName) else {
                throw "failed to get registered circuit data, circuit does not exist"
            }
            
            let circuitData = try await CircuitDataManager.shared.retriveCircuitData(registeredCircuitData)
            
            let registerIdentityLightInputs = try CircuitBuilderManager.shared.registerIdentityLightCircuit.buildInputs(user.secretKey, passport)
            
            let zkProof = try UserManager.shared.generateRegisterIdentityLightProof(
                registerIdentityLightInputs.json,
                circuitData,
                registeredCircuitData
            )
            
            let lightRegistrationService = LightRegistrationService(ConfigManager.shared.api.relayerURL)
            let registerResponse = try await lightRegistrationService.register(passport, zkProof)
            
            LoggerUtil.common.info("Passport light registration signature received")
            
            let stateKeeperContract = try StateKeeperContract()
            
            let passportInfoKey: String
            if passport.dg15.isEmpty {
                passportInfoKey = try BN(hex: registerResponse.data.attributes.passportHash).dec()
            } else {
                passportInfoKey = try BN(hex: registerResponse.data.attributes.publicKey).dec()
            }
            
            let profile = try IdentityProfile().newProfile(UserManager.shared.user?.secretKey)
            
            let currentIdentityKey = try profile.getPublicKeyHash()
            
            let (passportInfo, _) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
            
            if passportInfo.activeIdentity == currentIdentityKey {
                LoggerUtil.common.info("Passport is already registered")
                
                PassportManager.shared.setPassport(passport)
                try UserManager.shared.saveRegisterZkProof(zkProof)
                try UserManager.shared.saveLightRegistrationData(registerResponse.data.attributes)
                
                isUserRegistered = true
                proofState = .finalizing
                
                processingStatus = .success
                
                return zkProof
            }
            
            try await UserManager.shared.lightRegister(zkProof, registerResponse)
            
            PassportManager.shared.setPassport(passport)
            try UserManager.shared.saveRegisterZkProof(zkProof)
            try UserManager.shared.saveLightRegistrationData(registerResponse.data.attributes)
            
            try await NotificationManager.shared.subscribe(toTopic: ConfigManager.shared.general.claimableNotificationTopic)
            
            isUserRegistered = true
            
            LoggerUtil.common.info("Passport light registration succeed")
            
            try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
            proofState = .finalizing
            
            try await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            processingStatus = .success
            
            return zkProof
        } catch {
            processingStatus = .failure
            throw error
        }
    }
}
