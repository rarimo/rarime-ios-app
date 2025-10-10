import Alamofire
import Identity
import NFCPassportReader
import SwiftUI
import Web3

private let ENCAPSULATED_CONTENT_2688: Int = 2688
private let ENCAPSULATED_CONTENT_2704: Int = 2704
private let ZERO_IN_HEX: String = "0x303030303030"

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var user: User?
    
    @Published var registerZkProof: ZkProof?
    @Published var lightRegistrationData: LightRegistrationData?
    @Published var masterCertProof: SMTProof?
    
    @Published var isRevoked: Bool
    
    private var recentZKProofResult: Result<ZkProof, Error>?
    
    init() {
        do {
            // Data stored in Keychain cannot be deleted after uninstalling the app,
            // so we need to check Keychain on hits from previous installations
            // and delete all data that could not be deleted otherwise
            if AppUserDefaults.shared.isFirstLaunch {
                if try AppKeychain.containsValue(.privateKey) {
                    try AppKeychain.removeValue(.privateKey)
                    try AppKeychain.removeValue(.registerZkProof)
                    try AppKeychain.removeValue(.passport)
                    try AppKeychain.removeValue(.lightRegistrationData)
                }
                
                AppUserDefaults.shared.isFirstLaunch = false
            }
            
            self.user = try User.load()
            self.isRevoked = AppUserDefaults.shared.isUserRevoked
            
            if let registerZkProofJson = try AppKeychain.getValue(.registerZkProof) {
                if let grothZkProof = try? JSONDecoder().decode(GrothZkProof.self, from: registerZkProofJson) {
                    self.registerZkProof = .groth(grothZkProof)
                } else if let plonkZkProof = try? JSONDecoder().decode(Data.self, from: registerZkProofJson) {
                    self.registerZkProof = .plonk(plonkZkProof)
                } else {
                    throw UserManagerError.invalidZkProofFormat
                }
            }
            
            if let lightRegistrationData = try AppKeychain.getValue(.lightRegistrationData) {
                let lightRegistrationData = try JSONDecoder().decode(LightRegistrationData.self, from: lightRegistrationData)
                
                self.lightRegistrationData = lightRegistrationData
            }
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func createNewUser() throws {
        guard let secretKey = IdentityNewBJJSecretKey() else { throw UserManagerError.secretKeyNotGenerated }
        
        self.user = try User(secretKey: secretKey)
    }
    
    func createFromSecretKey(_ secretKey: Data) throws {
        self.user = try User(secretKey: secretKey)
    }
    
    func saveRegisterZkProof(_ zkProof: ZkProof) throws {
        let zkProofJson = try JSONEncoder().encode(zkProof)
        
        try AppKeychain.setValue(.registerZkProof, zkProofJson)
        
        self.registerZkProof = zkProof
    }
    
    func saveLightRegistrationData(_ lightRegistrationData: LightRegistrationData) throws {
        let lightRegistrationDataJson = try JSONEncoder().encode(lightRegistrationData)
        
        try AppKeychain.setValue(.lightRegistrationData, lightRegistrationDataJson)
        
        self.lightRegistrationData = lightRegistrationData
    }
    
    var userChallenge: Data {
        (try? self.user?.profile.getRegistrationChallenge()) ?? Data()
    }
    
    func generateRegisterIdentityLightProof(
        _ inputs: Data,
        _ circuitData: CircuitData,
        _ registeredCircuitData: RegisteredCircuitData
    ) throws -> ZkProof {
        var wtns: Data
        switch registeredCircuitData {
        case .registerIdentityLight160:
            wtns = try ZKUtils.calcWtns_registerIdentityLight160(circuitData.circuitDat, inputs)
        case .registerIdentityLight224:
            wtns = try ZKUtils.calcWtns_registerIdentityLight224(circuitData.circuitDat, inputs)
        case .registerIdentityLight256:
            wtns = try ZKUtils.calcWtns_registerIdentityLight256(circuitData.circuitDat, inputs)
        case .registerIdentityLight384:
            wtns = try ZKUtils.calcWtns_registerIdentityLight384(circuitData.circuitDat, inputs)
        case .registerIdentityLight512:
            wtns = try ZKUtils.calcWtns_registerIdentityLight512(circuitData.circuitDat, inputs)
        default:
            throw UserManagerError.invalidRegisteredLightCircuitData
        }
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(circuitData.circuitZkey, wtns)
        
        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)
        
        return ZkProof.groth(GrothZkProof(proof: proof, pubSignals: pubSignals))
    }
    
    func generateRegisterIdentityProof(
        _ inputs: Data,
        _ circuitData: CircuitData,
        _ registeredCircuitData: RegisteredCircuitData
    ) throws -> ZkProof {
        defer { self.recentZKProofResult = nil }
        
        let thread = Thread {
            do {
                let proof = try self._generateRegisterIdentityProof(inputs, circuitData, registeredCircuitData)
                
                self.recentZKProofResult = .success(proof)
            } catch {
                self.recentZKProofResult = .failure(error)
            }
            
            Thread.current.cancel()
        }
        
        thread.stackSize = 16 * 1024 * 1024
        
        thread.start()
        
        while self.recentZKProofResult == nil {
            Thread.sleep(forTimeInterval: 1)
        }
        
        switch self.recentZKProofResult {
        case .success(let proof):
            return proof
        case .failure(let error):
            throw error
        case .none:
            throw UserManagerError.invalidProof
        }
    }
    
    func _generateRegisterIdentityProof(
        _ inputs: Data,
        _ circuitData: CircuitData,
        _ registeredCircuitData: RegisteredCircuitData
    ) throws -> ZkProof {
        var wtns: Data
        switch registeredCircuitData {
        case .registerIdentity_21_256_3_7_336_264_21_3072_6_2008:
            wtns = try ZKUtils.calcWtns_registerIdentity_21_256_3_7_336_264_21_3072_6_2008(circuitData.circuitDat, inputs)
        case .registerIdentity_14_256_3_4_336_64_1_1480_5_296:
            wtns = try ZKUtils.calcWtns_registerIdentity_14_256_3_4_336_64_1_1480_5_296(circuitData.circuitDat, inputs)
        case .registerIdentity_1_256_3_6_336_560_1_2744_4_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_256_3_6_336_560_1_2744_4_256(circuitData.circuitDat, inputs)
        case .registerIdentity_20_256_3_5_336_72_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_20_256_3_5_336_72_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_4_160_3_3_336_216_1_1296_3_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_4_160_3_3_336_216_1_1296_3_256(circuitData.circuitDat, inputs)
        case .registerIdentity_20_160_3_3_736_200_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_20_160_3_3_736_200_NA(circuitData.circuitDat, inputs)
        default:
            throw UserManagerError.invalidRegisteredCircuitData
        }
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(circuitData.circuitZkey, wtns)
        
        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)
        
        return ZkProof.groth(GrothZkProof(proof: proof, pubSignals: pubSignals))
    }
    
    func register(_ registerZkProof: ZkProof, _ passport: Passport, _ isRevoked: Bool, _ registerIdentityCircuitName: String) async throws {
        let slaveCertPem = try passport.getSlaveSodCertificatePem()
        
        let masterCertProof = try await passport.getCertificateSmtProof(slaveCertPem)
        
        let sod = try passport.getSod()
        let ec = try sod.getEncapsulatedContent()
        
        let calldataBuilder = IdentityCallDataBuilder()
        
        let calldata: Data
        switch registerZkProof {
        case .groth(let proof):
            calldata = try calldataBuilder.buildRegisterCalldata(
                proof.json,
                aaSignature: passport.signature,
                aaPubKeyPem: passport.getDG15PublicKeyPEM(),
                ecSizeInBits: ec.count * 8,
                certificatesRootRaw: masterCertProof.root,
                isRevoked: isRevoked,
                circuitName: registerIdentityCircuitName
            )
        case .plonk(let data):
            calldata = try calldataBuilder.buildNoirRegisterCalldata(
                data,
                aaSignature: passport.signature,
                aaPubKeyPem: passport.getDG15PublicKeyPEM(),
                ecSizeInBits: ec.count * 8,
                certificatesRootRaw: masterCertProof.root,
                isRevoked: isRevoked,
                circuitName: registerIdentityCircuitName
            )
        }
        
        let relayer = Relayer(ConfigManager.shared.general.appApiURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.contracts.registration2Address)
        
        LoggerUtil.common.info("Passport register EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func lightRegister(_ registerZKProof: ZkProof, _ verifySodResponse: VerifySodResponse) async throws {
        guard let signature = Data(hex: verifySodResponse.data.attributes.signature) else {
            throw UserManagerError.invalidSignature
        }
        
        guard let passportHash = Data(hex: verifySodResponse.data.attributes.passportHash) else {
            throw UserManagerError.invalidPassportHash
        }
        
        guard let publicKey = Data(hex: verifySodResponse.data.attributes.publicKey) else {
            throw UserManagerError.invalidPublicKey
        }
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRegisterSimpleCalldata(
            registerZKProof.json,
            signature: signature,
            passportHash: passportHash,
            publicKey: publicKey,
            verifierAddress: verifySodResponse.data.attributes.verifier
        )
        
        let relayer = Relayer(ConfigManager.shared.general.appApiURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.contracts.registrationSimpleAddress, false)
        
        LoggerUtil.common.info("Passport light register EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func revoke(_ passportInfo: PassportInfo, _ passport: Passport) async throws {
        let identityKey = passportInfo.activeIdentity
        
        let signature = passport.signature
        
        let sod = try passport.getSod()
        
        let ec = try sod.getEncapsulatedContent()
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRevoceCalldata(
            identityKey,
            aaSignature: signature,
            aaPubKeyPem: passport.getDG15PublicKeyPEM(),
            ecSizeInBits: ec.count * 8
        )
        
        let relayer = Relayer(ConfigManager.shared.general.appApiURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.contracts.registration2Address)
        
        LoggerUtil.common.info("Passport revoke EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func registerCertificate(_ passport: Passport) async throws {
        let certificatesSMTAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.certificatesSmtAddress, eip55: false)
        let certificatesSMTContract = try PoseidonSMT(contractAddress: certificatesSMTAddress)
        
        let sod = try SOD([UInt8](passport.sod))
        
        guard let cert = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.pkcs7CertificateData)).first else {
            throw PassportError.missingSlaveCertificate
        }
        
        let certPem = cert.certToPEM().data(using: .utf8) ?? Data()
        let slaveCertificateIndex = try IdentityX509Util().getSlaveCertificateIndex(certPem, mastersPem: Certificates.ICAO)
        
        let proof = try await certificatesSMTContract.getProof(slaveCertificateIndex)
        
        if proof.existence {
            LoggerUtil.common.info("Passport certificate is already registered")
            
            return
        }
        
        LoggerUtil.common.info("Passport certificate is not registered, registering...")
        
        let buildCalldataResponse = try IdentityCallDataBuilder().buildRegisterCertificateCalldata(Certificates.ICAO, slavePem: certPem)
        
        guard let calldata = buildCalldataResponse.calldata else {
            throw UserManagerError.calldataBuildFailed
        }
        
        let relayer = Relayer(ConfigManager.shared.general.appApiURL)
        let response = try await relayer.register(
            calldata,
            ConfigManager.shared.contracts.registration2Address,
            meta: ["dispatcherName": buildCalldataResponse.dispatcherName]
        )
        
        LoggerUtil.common.info("Register certificate EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func generateQueryProof(
        passport: Passport,
        params: GetProofParamsResponseAttributes
    ) async throws -> ZkProof {
        guard let secretKey = self.user?.secretKey else { throw UserManagerError.secretKeyNotInitialized }
        
        let stateKeeperContract = try StateKeeperContract()
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.registrationSmtAddress, eip55: false)
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        guard let passportKey = getPassportKey(passport) else {
            throw UserManagerError.passportKeyNotFound
        }
        
        guard let identityKey = getIdentityKey(passport) else {
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
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportKey)

        let timestampUpperBound = try UInt64(hexString: BN(dec: params.timestampUpperBound).hex()) ?? 0
        
        let queryProofInputs = try profile.buildQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: params.selector,
            pkPassportHash: passportKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: params.eventID,
            eventData: params.eventData,
            timestampLowerbound: params.timestampLowerBound,
            timestampUpperbound: max(
                timestampUpperBound,
                identityInfo.issueTimestamp + 1
            ).description,
            identityCounterLowerbound: params.identityCounterLowerBound.description,
            identityCounterUpperbound: (passportInfo.identityReissueCounter + 1).description,
            expirationDateLowerbound: params.expirationDateLowerBound,
            expirationDateUpperbound: params.expirationDateUpperBound,
            birthDateLowerbound: params.birthDateLowerBound,
            birthDateUpperbound: params.birthDateUpperBound,
            citizenshipMask: params.citizenshipMask
        )
        
        let wtns = try ZKUtils.calcWtns_queryIdentity(Circuits.queryIdentityDat, queryProofInputs)
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)
        
        return ZkProof.groth(GrothZkProof(proof: proof, pubSignals: pubSignals))
    }
    
    func collectPubSignals(
        passport: Passport,
        params: GetProofParamsResponseAttributes
    ) throws -> GrothZkProofPubSignals {
        let nullifier = try generateNullifierForEvent(params.eventID)
        let currentTimestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        
        var calculateAnonymousIDError: NSError?
        let anonymousID = IdentityCalculateAnonymousID(passport.dg1, Points.PointsEventId, &calculateAnonymousIDError)
        if let calculateAnonymousIDError {
            throw calculateAnonymousIDError
        }
        
        guard let anonymousID else {
            throw UserManagerError.anonymousIDNotCalculated
        }
        
        return [
            nullifier.toBigUInt(),
            ZERO_IN_HEX.toBigUInt(),
            ZERO_IN_HEX.toBigUInt(),
            "0",
            "0",
            "0",
            passport.issuingAuthority.toBigUInt(toUTF8: true),
            passport.gender.toBigUInt(toUTF8: true),
            "0",
            params.eventID.toBigUInt(),
            params.eventData.toBigUInt(),
            BN(anonymousID).dec(),
            params.selector.toBigUInt(),
            currentTimestamp.toBigUInt(),
            params.timestampLowerBound.toBigUInt(),
            params.timestampUpperBound.toBigUInt(),
            params.identityCounterLowerBound.description.toBigUInt(),
            params.identityCounterUpperBound.description.toBigUInt(),
            params.birthDateLowerBound.toBigUInt(),
            params.birthDateUpperBound.toBigUInt(),
            params.expirationDateLowerBound.toBigUInt(),
            params.expirationDateUpperBound.toBigUInt(),
            params.citizenshipMask.toBigUInt()
        ]
    }
    
    func generatePointsProof(_ passport: Passport) async throws -> ZkProof {
        guard let secretKey = self.user?.secretKey else { throw UserManagerError.secretKeyNotInitialized }
        
        let stateKeeperContract = try StateKeeperContract()
        
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.registrationSmtAddress, eip55: false)
        
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        guard let passportKey = getPassportKey(passport) else {
            throw UserManagerError.passportKeyNotFound
        }
        
        guard let identityKey = getIdentityKey(passport) else {
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
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportKey)
        
        let queryProofInputs = try profile.buildAirdropQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: "23073",
            pkPassportHash: passportKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: Points.PointsEventId,
            startedAt: 1715688000
        )
        
        let wtns = try ZKUtils.calcWtns_queryIdentity(Circuits.queryIdentityDat, queryProofInputs)
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(GrothZkProofPoints.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(GrothZkProofPubSignals.self, from: pubSignalsJson)
        
        return ZkProof.groth(GrothZkProof(proof: proof, pubSignals: pubSignals))
    }
    
    func fetchPointsBalance(_ jwt: JWT) async throws -> PointsBalanceRaw {
        let points = Points(ConfigManager.shared.general.appApiURL)
        
        let balanceResponse = try await points.getPointsBalance(jwt, true, true)
        
        return balanceResponse.data.attributes
    }
    
    func reserveTokens(_ jwt: JWT, _ passport: Passport) async throws {
        let queryProof = try await generatePointsProof(passport)
        
        var calculateAnonymousIDError: NSError?
        let anonymousID = IdentityCalculateAnonymousID(passport.dg1, Points.PointsEventId, &calculateAnonymousIDError)
        if let calculateAnonymousIDError {
            throw calculateAnonymousIDError
        }
        
        var error: NSError?
        let hmacMessage = IdentityCalculateHmacMessage(jwt.payload.sub, passport.nationality, anonymousID, &error)
        if let error {
            throw error
        }
        
        let key = Data(hex: ConfigManager.shared.secrets.joinRewardsKey) ?? Data()
        
        let hmacSingature = HMACUtils.hmacSha256(hmacMessage ?? Data(), key)
        
        let points = Points(ConfigManager.shared.general.appApiURL)
        let _ = try await points.verifyPassport(
            jwt,
            queryProof,
            hmacSingature.hex,
            passport.nationality,
            anonymousID?.hex ?? ""
        )
        
        LoggerUtil.common.info("Passport verified, token reserved")
    }
    
    func reset() {
        AppUserDefaults.shared.isUserRevoked = false
        AppUserDefaults.shared.userReferralCode = ""
        AppUserDefaults.shared.deferredReferralCode = ""
        AppUserDefaults.shared.userStatus = User.Status.unscanned.rawValue
        
        do {
            try AppKeychain.removeValue(.privateKey)
            try AppKeychain.removeValue(.registerZkProof)
            try AppKeychain.removeValue(.passport)
            try AppKeychain.removeValue(.lightRegistrationData)
            
            self.user = nil
            self.registerZkProof = nil
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func generateNullifierForEvent(_ eventId: String) throws -> String {
        guard let user else { throw UserManagerError.userNotInitialized }
        
        var error: NSError?
        let nullifier = user.profile.calculateEventNullifierHex(eventId, error: &error)
        if let error { throw error }
        
        return nullifier
    }
    
    func getPassportKey(_ passport: Passport) -> String? {
        guard let registerZkProof else { return nil }
        
        let registerIdentityPubSignals = RegisterIdentityPubSignals(registerZkProof)
        
        var passportKey: String
        switch registerIdentityPubSignals.raw.count {
        case RegisterIdentityPubSignals.SignalKey.allCases.count:
            
            if passport.dg15.isEmpty {
                passportKey = registerIdentityPubSignals.getSignalRaw(.passportHash)
            } else {
                passportKey = registerIdentityPubSignals.getSignalRaw(.passportKey)
            }
        case RegisterIdentityLightPubSignals.SignalKey.allCases.count:
            guard let lightRegistrationData else {
                return nil
            }
            
            if passport.dg15.isEmpty {
                return try? BN(hex: lightRegistrationData.passportHash).dec()
            } else {
                return try? BN(hex: lightRegistrationData.publicKey).dec()
            }
        default:
            return nil
        }
        
        return passportKey
    }
    
    func getIdentityKey(_ passport: Passport) -> String? {
        guard let registerZkProof else { return nil }
        switch registerZkProof {
        case .groth(let grothZkProof):
            switch grothZkProof.pubSignals.count {
            case RegisterIdentityPubSignals.SignalKey.allCases.count:
                let pubSignals = RegisterIdentityPubSignals(grothZkProof.pubSignals)
                
                return pubSignals.getSignalRaw(.identityKey)
            case RegisterIdentityLightPubSignals.SignalKey.allCases.count:
                let pubSignals = RegisterIdentityLightPubSignals(grothZkProof.pubSignals)
                
                return pubSignals.getSignalRaw(.identityKey)
            default:
                return nil
            }
        case .plonk(let data):
            return RegisterIdentityPubSignals(data).getSignalRaw(.identityKey)
        }
    }
    
    var ethereumAddress: String? {
        guard let user else { return nil }
        
        guard let ethereumPrivateKey = try? EthereumPrivateKey(privateKey: user.secretKey.makeBytes()) else {
            return nil
        }
        
        return ethereumPrivateKey.address.hex(eip55: true)
    }
}

enum UserManagerError: Error {
    case userNotInitialized
    case passportKeyNotFound
    case identityKeyNotFound
    case secretKeyNotInitialized
    case proofIndexNotInitialized
    case invalidSignature
    case invalidPassportHash
    case invalidPublicKey
    case invalidCircuitData
    case invalidRegisteredCircuitData
    case invalidRegisteredLightCircuitData
    case invalidProof
    case anonymousIDNotCalculated
    case calldataBuildFailed
    case invalidZkProofFormat
    case secretKeyNotGenerated

    var localizedDescription: String {
        switch self {
        case .userNotInitialized:
            return "User is not initialized"
        case .passportKeyNotFound:
            return "Failed to get passport key"
        case .identityKeyNotFound:
            return "Failed to get identity key"
        case .secretKeyNotInitialized:
            return "Secret key is not initialized"
        case .proofIndexNotInitialized:
            return "Proof index is not initialized"
        case .invalidSignature:
            return "Invalid signature"
        case .invalidPassportHash:
            return "Invalid passport hash"
        case .invalidPublicKey:
            return "Invalid public key"
        case .invalidCircuitData:
            return "Invalid circuit data"
        case .invalidRegisteredCircuitData:
            return "Invalid registered circuit data"
        case .invalidRegisteredLightCircuitData:
            return "Invalid registered light circuit data"
        case .invalidProof:
            return "Invalid proof"
        case .anonymousIDNotCalculated:
            return "Failed to calculate anonymous ID"
        case .calldataBuildFailed:
            return "Failed to build calldata"
        case .invalidZkProofFormat:
            return "Invalid ZK Proof format"
        case .secretKeyNotGenerated:
            return "Failed to generate secret key"
        }
    }
}
