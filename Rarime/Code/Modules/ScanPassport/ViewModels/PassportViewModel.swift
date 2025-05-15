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
        case .downloadingData: 0
        case .applyingZK: 18
        case .createProfile: 8
        case .finalizing: 2
        }
    }
    
    var simulationDurationNanoseconds: UInt64 {
        UInt64(simulationDuration * 1_000_000_000)
    }
}

class PassportViewModel: ObservableObject {
    @Published var mrzKey: String?
    @Published var proofState: PassportProofState = .downloadingData {
        didSet {
            if proofState != .downloadingData {
                startProgressSimulation(for: proofState)
            }
        }
    }
    
    @Published var processingStatus: PassportProcessingStatus = .init(rawValue: AppUserDefaults.shared.passportProcessingStatus) ?? .processing {
        didSet {
            AppUserDefaults.shared.passportProcessingStatus = processingStatus.rawValue
        }
    }

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
    private let stepFraction: Double = 1.0 / Double(PassportProofState.allCases.count)
    
    var revocationPassportPublisher = PassthroughSubject<Passport, Error>()
    
    func setMrzKey(_ value: String) {
        mrzKey = value
        
        AppUserDefaults.shared.lastMRZKey = value
    }

    @MainActor
    func register() async throws -> ZkProof {
        var isCriticalRegistrationProcessInProgress = true
        
        AppUserDefaults.shared.isRegistrationInterrupted = false
        
        do {
#if DEVELOPMENT
            if DebugManager.shared.shouldForceLightRegistration {
                throw "DEBUG"
            }
#endif
            
            guard let passport = PassportManager.shared.passport else { throw "failed to get passport" }
            guard let user = UserManager.shared.user else { throw "failed to get user" }
            
            try await UserManager.shared.registerCertificate(passport)
            
            guard let registerIdentityCircuitType = try passport.getRegisterIdentityCircuitType() else {
                throw "failed to get register identity circuit"
            }
            
            guard let registerIdentityCircuitName = registerIdentityCircuitType.buildName() else {
                throw "failed to get register identity circuit name"
            }
            
            LoggerUtil.common.info("Registering passport with circuit: \(registerIdentityCircuitName)")
            
            var proof: ZkProof
            if let registeredCircuitData = RegisteredCircuitData(rawValue: registerIdentityCircuitName) {
                proof = try await generateGrothRegisterProof(
                    user,
                    passport,
                    registerIdentityCircuitType,
                    registeredCircuitData,
                    &isCriticalRegistrationProcessInProgress
                )
            } else if let registeredCircuitData = RegisteredNoirCircuitData(rawValue: registerIdentityCircuitName) {
                proof = try await generatePlonkRegisterProof(
                    user,
                    passport,
                    registerIdentityCircuitType,
                    registeredCircuitData,
                    &isCriticalRegistrationProcessInProgress
                )
            } else {
                throw "failed to get registered circuit data, circuit does not exist"
            }
            
            LoggerUtil.common.info("Passport registration proof generated")
            
            completeCurrentStepProgress()
            proofState = .createProfile
            
            let stateKeeperContract = try StateKeeperContract()
            
            let registerProofPubSignals = RegisterIdentityPubSignals(proof)
            
            let passportInfoKey: String
            if passport.dg15.isEmpty {
                passportInfoKey = registerProofPubSignals.getSignalRaw(.passportHash)
            } else {
                passportInfoKey = registerProofPubSignals.getSignalRaw(.passportKey)
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
            
            var isUserRevoking = passportInfo.activeIdentity != Ethereum.ZERO_BYTES32
#if DEVELOPMENT
            if DebugManager.shared.shouldForceRegistration {
                isUserRevoking = false
            }
#endif
            
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
                    LoggerUtil.common.error("Revocation scan failed: \(error, privacy: .public)")
                    
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
            if "\(error)".contains("invalid passport authentication") {
                processingStatus = .failure
                
                throw Errors.unknown("Active authentication signature is invalid")
            }
            
            if !isCriticalRegistrationProcessInProgress {
                processingStatus = .failure
                
                throw error
            }
            
            LoggerUtil.common.error("Trying light registration because of: \(error.localizedDescription, privacy: .public)")
            
            do {
                return try await lightRegister()
            } catch {
                processingStatus = .failure
                
                throw error
            }
        }
    }
    
    func generateGrothRegisterProof(
        _ user: User,
        _ passport: Passport,
        _ registerIdentityCircuitType: RegisterIdentityCircuitType,
        _ registeredCircuitData: RegisteredCircuitData,
        _ isCriticalRegistrationProcessInProgress: inout Bool
    ) async throws -> ZkProof {
        isCriticalRegistrationProcessInProgress = false
        
        let circuitData: CircuitData
        do {
            circuitData = try await DownloadableDataManager.shared.retriveCircuitData(registeredCircuitData) { progress in
                self.updateDownloadProgress(downloadProgressValue: progress)
            }
        } catch {
            throw Errors.unknown("Failed to download data, internet connection is unstable")
        }
        
        updateDownloadProgress(downloadProgressValue: 1)
        
        isCriticalRegistrationProcessInProgress = true
        
        completeCurrentStepProgress()
        proofState = .applyingZK
        
        let registerIdentityInputs = try await CircuitBuilderManager.shared.registerIdentityCircuit.buildInputs(
            user.secretKey,
            passport,
            registerIdentityCircuitType
        )
        
        let proof = try await Task.detached {
            try UserManager.shared.generateRegisterIdentityProof(registerIdentityInputs.json, circuitData, registeredCircuitData)
        }.value
        
        return proof
    }
    
    func generatePlonkRegisterProof(
        _ user: User,
        _ passport: Passport,
        _ registerIdentityCircuitType: RegisterIdentityCircuitType,
        _ registeredNoirCircuitData: RegisteredNoirCircuitData,
        _ isCriticalRegistrationProcessInProgress: inout Bool
    ) async throws -> ZkProof {
        isCriticalRegistrationProcessInProgress = false
        
        let trustedSetupPath = try await DownloadableDataManager.shared.retriveNoirCircuitDataPath(.trustedSetup) { progress in
            self.updateDownloadProgress(downloadProgressValue: progress)
        }
        
        let circuitDataPath: URL
        do {
            circuitDataPath = try await DownloadableDataManager.shared.retriveNoirCircuitDataPath(registeredNoirCircuitData)
        } catch {
            throw Errors.unknown("Failed to download data, internet connection is unstable")
        }
        
        updateDownloadProgress(downloadProgressValue: 1)
        
        isCriticalRegistrationProcessInProgress = true
        
        completeCurrentStepProgress()
        proofState = .applyingZK
        
        let registerIdentityInputs = try await CircuitBuilderManager.shared.noirRegisterIdentityCircuit.buildInputs(
            user.secretKey,
            passport,
            registerIdentityCircuitType
        )
        
        guard let circuitData = FileManager.default.contents(atPath: circuitDataPath.path()) else {
            throw Errors.unknown("Failed to read circuit data")
        }
        
        let proof = try await Task.detached {
            try ZKUtils.ultraPlonk(
                trustedSetupPath.path(),
                circuitData,
                registerIdentityInputs.toAnyMap()
            )
        }.value
        
        return ZkProof.plonk(proof)
    }
    
    @MainActor
    func lightRegister() async throws -> ZkProof {
        do {
            guard let passport = PassportManager.shared.passport else { throw "failed to get passport" }
            guard let user = UserManager.shared.user else { throw "failed to get user" }
            
            let registerIdentityLightCircuitName = try passport.getRegisterIdentityLightCircuitName()
            
            LoggerUtil.common.info("Registering passport with light circuit: \(registerIdentityLightCircuitName, privacy: .public)")
            
            guard let registeredCircuitData = RegisteredCircuitData(rawValue: registerIdentityLightCircuitName) else {
                throw "failed to get registered circuit data, circuit does not exist"
            }
            
            let circuitData = try await DownloadableDataManager.shared.retriveCircuitData(registeredCircuitData)
            
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
        overallProgress = min(downloadProgressValue * stepFraction, stepFraction)
    }
    
    func startProgressSimulation(for state: PassportProofState) {
        let simulationDuration = state.simulationDuration
        let startProgress = overallProgress
        let targetProgress = min(startProgress + stepFraction, 1.0)
        
        simulationStartTime = Date()
        progressTimer?.cancel()
        
        progressTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      let startTime = self.simulationStartTime else { return }
                
                if self.isPaused { return }
                            
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
       
        let targetProgress = min(overallProgress + stepFraction, 1.0)
        overallProgress = targetProgress
        progressTimer?.cancel()
    }
}
