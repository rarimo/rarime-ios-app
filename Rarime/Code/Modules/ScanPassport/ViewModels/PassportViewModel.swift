import Combine
import Identity
import SwiftUI
import Web3

enum PassportProofState: Int, CaseIterable {
    case downloadingData, applyingZK, createProfile, finalizing

    var title: LocalizedStringResource {
        switch self {
        case .downloadingData: "Downloading"
        case .applyingZK: "Applying ZK"
        case .createProfile: "Creating"
        case .finalizing: "Finalizing"
        }
    }
    
    var simulationDuration: TimeInterval {
        switch self {
        case .downloadingData: return 0
        case .applyingZK:     return 18
        case .createProfile:  return 8
        case .finalizing:     return 2
        }
    }
    
    var simulationDurationNanoseconds: UInt64 {
        UInt64(simulationDuration * 1_000_000_000)
    }
}

enum ProcessingStatus: Equatable {
    case processing, success, failure
}

class PassportViewModel: ObservableObject {
    @Published var mrzKey: String?
    @Published var passport: Passport?
    @Published var proofState: PassportProofState = .downloadingData {
        didSet {
            if proofState != .downloadingData {
                startProgressSimulation(for: proofState)
            }
        }
    }
    
    @Published var processingStatus: ProcessingStatus = .processing
    @Published var overallProgress: Double = 0.0

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
    
    private var progressTimer: AnyCancellable?
    private var simulationStartTime: Date?
    private var isPaused: Bool = false
    
    var revocationPassportPublisher = PassthroughSubject<Passport, Error>()
    
    func setMrzKey(_ value: String) {
        self.mrzKey = value
    }

    func setPassport(_ passport: Passport) {
        self.passport = passport
    }

    @MainActor
    func register() async throws -> ZkProof {
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
            
            let circuitData: CircuitData
            do {
                circuitData = try await CircuitDataManager.shared.retriveCircuitData(registeredCircuitData) { progress in
                    self.updateDownloadProgress(downloadProgressValue: progress)
                }
            } catch {
                throw Errors.unknown("Failed to download data, internet connection is unstable")
            }
            
            if overallProgress < 0.25 { overallProgress = 0.25 }
            
            isCriticalRegistrationProcessInProgress = true
            
            completeCurrentStepProgress()
            proofState = .applyingZK
            
            let registerIdentityInputs = try await Task.detached {
                return try await CircuitBuilderManager.shared.registerIdentityCircuit.buildInputs(
                    user.secretKey,
                    passport,
                    registerIdentityCircuitType
                )
            }.value
            
            let proof = try await Task.detached {
                return try UserManager.shared.generateRegisterIdentityProof(registerIdentityInputs.json, circuitData, registeredCircuitData)
            }.value
            
            LoggerUtil.common.info("Passport registration proof generated")
            
            completeCurrentStepProgress()
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
                
                try await Task.sleep(nanoseconds: proofState.simulationDurationNanoseconds)
                completeCurrentStepProgress()
                proofState = .finalizing
                
                try await Task.sleep(nanoseconds: proofState.simulationDurationNanoseconds)
                completeCurrentStepProgress()
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
                isCriticalRegistrationProcessInProgress = false
                
                if passport.dg15.isEmpty {
                    throw Errors.unknown("You can't register with already used passport")
                }
                
                isCriticalRegistrationProcessInProgress = true
                
                // takes last 8 bytes of activeIdentity as revocation challenge
                revocationChallenge = passportInfo.activeIdentity[24 ..< 32]
                
                // This will trigger a sheet with a NFC scanning
                self.isUserRevoking = isUserRevoking
                
                var iterator = revocationPassportPublisher.values.makeAsyncIterator()
                
                isCriticalRegistrationProcessInProgress = false
                
                let passport: Passport
                do {
                    guard let newPassport = try await iterator.next() else {
                        throw "failed to get passport"
                    }
                    
                    passport = newPassport
                } catch {
                    throw Errors.unknown("Failed to read document, try again")
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
            
            try await Task.sleep(nanoseconds: proofState.simulationDurationNanoseconds)
            completeCurrentStepProgress()
            proofState = .finalizing
            
            try await Task.sleep(nanoseconds: proofState.simulationDurationNanoseconds)
            completeCurrentStepProgress()
            processingStatus = .success
            
            return proof
        } catch {
            if !isCriticalRegistrationProcessInProgress {
                processingStatus = .failure
                
                throw error
            }
            
            LoggerUtil.common.error("Trying light registration because of: \(error.localizedDescription)")
            
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
    
    func updateDownloadProgress(downloadProgressValue: Double) {
        overallProgress = min(downloadProgressValue * 0.25, 0.25)
    }
    
    func startProgressSimulation(for state: PassportProofState) {
        let simulationDuration = state.simulationDuration
        let stepProgress: Double = 0.25
        let startProgress = overallProgress
        let targetProgress = min(startProgress + stepProgress, 1.0)
        
        simulationStartTime = Date()
        progressTimer?.cancel()
        
        progressTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      let startTime = self.simulationStartTime else { return }
                
                guard !self.isPaused else { return }
                            
                if Double.random(in: 0...1) < 0.4 {
                    let pauseDuration = Double.random(in: 0.1...1)
                    self.isPaused = true
                    Task {
                        try await Task.sleep(nanoseconds: UInt64(pauseDuration * 1_000_000_000))
                        self.isPaused = false
                    }
                    return
                }
                
                let elapsed = Date().timeIntervalSince(startTime)
                
                if elapsed >= simulationDuration {
                    self.overallProgress = targetProgress
                    self.progressTimer?.cancel()
                } else {
                    let remaining = targetProgress - self.overallProgress
                    let randomIncrement = min(remaining, Double.random(in: 0.005...0.01))
                    self.overallProgress = min(self.overallProgress + randomIncrement, targetProgress)
                }
            }
    }
    
    func completeCurrentStepProgress() {
        guard let state = PassportProofState.allCases.first(where: { $0 == proofState }),
             state != .downloadingData else { return }
       
        let targetProgress = min(overallProgress + 0.25, 1.0)
        overallProgress = targetProgress
        progressTimer?.cancel()
   }
}
