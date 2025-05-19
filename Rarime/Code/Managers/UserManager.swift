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
    
    @Published var balance: Double
    
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
            self.balance = 0
            self.isRevoked = AppUserDefaults.shared.isUserRevoked
            
            if let registerZkProofJson = try AppKeychain.getValue(.registerZkProof) {
                if let grothZkProof = try? JSONDecoder().decode(GrothZkProof.self, from: registerZkProofJson) {
                    self.registerZkProof = .groth(grothZkProof)
                } else if let plonkZkProof = try? JSONDecoder().decode(Data.self, from: registerZkProofJson) {
                    self.registerZkProof = .plonk(plonkZkProof)
                } else {
                    throw "failed to decode registerZkProof"
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
        guard let secretKey = IdentityNewBJJSecretKey() else { throw "failed to create new secret key" }
        
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
    
    var userAddress: String {
        self.user?.profile.getRarimoAddress() ?? "undefined"
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
            throw "invalid register identity light circuit"
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
            throw "failed to get proof"
        }
    }
    
    func _generateRegisterIdentityProof(
        _ inputs: Data,
        _ circuitData: CircuitData,
        _ registeredCircuitData: RegisteredCircuitData
    ) throws -> ZkProof {
        var wtns: Data
        switch registeredCircuitData {
        case .registerIdentity_1_256_3_6_576_248_1_2432_5_296:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_256_3_6_576_248_1_2432_5_296(circuitData.circuitDat, inputs)
        case .registerIdentity_21_256_3_7_336_264_21_3072_6_2008:
            wtns = try ZKUtils.calcWtns_registerIdentity_21_256_3_7_336_264_21_3072_6_2008(circuitData.circuitDat, inputs)
        case .registerIdentity_11_256_3_3_576_248_1_1184_5_264:
            wtns = try ZKUtils.calcWtns_registerIdentity_11_256_3_3_576_248_1_1184_5_264(circuitData.circuitDat, inputs)
        case .registerIdentity_12_256_3_3_336_232_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_12_256_3_3_336_232_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_1_256_3_4_336_232_1_1480_5_296:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_256_3_4_336_232_1_1480_5_296(circuitData.circuitDat, inputs)
        case .registerIdentity_1_160_3_3_576_200_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_160_3_3_576_200_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_21_256_3_3_336_232_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_21_256_3_3_336_232_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_24_256_3_4_336_232_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_24_256_3_4_336_232_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_1_256_3_3_576_248_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_256_3_3_576_248_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_11_256_3_5_576_248_1_1808_4_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_11_256_3_5_576_248_1_1808_4_256(circuitData.circuitDat, inputs)
        case .registerIdentity_2_256_3_6_336_264_1_2448_3_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_2_256_3_6_336_264_1_2448_3_256(circuitData.circuitDat, inputs)
        case .registerIdentity_3_160_3_3_336_200_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_3_160_3_3_336_200_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_3_160_3_4_576_216_1_1512_3_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_3_160_3_4_576_216_1_1512_3_256(circuitData.circuitDat, inputs)
        case .registerIdentity_11_256_3_3_576_240_1_864_5_264:
            wtns = try ZKUtils.calcWtns_registerIdentity_11_256_3_3_576_240_1_864_5_264(circuitData.circuitDat, inputs)
        case .registerIdentity_11_256_3_5_576_248_1_1808_5_296:
            wtns = try ZKUtils.calcWtns_registerIdentity_11_256_3_5_576_248_1_1808_5_296(circuitData.circuitDat, inputs)
        case .registerIdentity_11_256_3_3_336_248_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_11_256_3_3_336_248_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_14_256_3_4_336_64_1_1480_5_296:
            wtns = try ZKUtils.calcWtns_registerIdentity_14_256_3_4_336_64_1_1480_5_296(circuitData.circuitDat, inputs)
        case .registerIdentity_21_256_3_5_576_232_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_21_256_3_5_576_232_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_1_256_3_6_336_560_1_2744_4_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_256_3_6_336_560_1_2744_4_256(circuitData.circuitDat, inputs)
        case .registerIdentity_1_256_3_6_336_248_1_2744_4_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_1_256_3_6_336_248_1_2744_4_256(circuitData.circuitDat, inputs)
        case .registerIdentity_20_256_3_5_336_72_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_20_256_3_5_336_72_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_4_160_3_3_336_216_1_1296_3_256:
            wtns = try ZKUtils.calcWtns_registerIdentity_4_160_3_3_336_216_1_1296_3_256(circuitData.circuitDat, inputs)
        case .registerIdentity_15_512_3_3_336_248_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_15_512_3_3_336_248_NA(circuitData.circuitDat, inputs)
        case .registerIdentity_20_160_3_3_736_200_NA:
            wtns = try ZKUtils.calcWtns_registerIdentity_20_160_3_3_736_200_NA(circuitData.circuitDat, inputs)
        default:
            throw "invalid register identity circuit"
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
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.api.registerContractAddress)
        
        LoggerUtil.common.info("Passport register EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func lightRegister(_ registerZKProof: ZkProof, _ verifySodResponse: VerifySodResponse) async throws {
        guard let signature = Data(hex: verifySodResponse.data.attributes.signature) else {
            throw "Invalid signature"
        }
        
        guard let passportHash = Data(hex: verifySodResponse.data.attributes.passportHash) else {
            throw "Invalid passport hash"
        }
        
        guard let publicKey = Data(hex: verifySodResponse.data.attributes.publicKey) else {
            throw "Invalid public key"
        }
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRegisterSimpleCalldata(
            registerZKProof.json,
            signature: signature,
            passportHash: passportHash,
            publicKey: publicKey,
            verifierAddress: verifySodResponse.data.attributes.verifier
        )
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.api.registrationSimpleContractAddress, false)
        
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
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.api.registerContractAddress)
        
        LoggerUtil.common.info("Passport revoke EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func registerCertificate(_ passport: Passport) async throws {
        let certificatesSMTAddress = try EthereumAddress(hex: ConfigManager.shared.api.certificatesSmtContractAddress, eip55: false)
        let certificatesSMTContract = try PoseidonSMT(contractAddress: certificatesSMTAddress)
        
        let sod = try SOD([UInt8](passport.sod))
        
        guard let cert = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.pkcs7CertificateData)).first else {
            throw "Slave certificate in sod is missing"
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
            throw "calldata build response does not contain calldata"
        }
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(
            calldata,
            ConfigManager.shared.api.registerContractAddress,
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
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let stateKeeperContract = try StateKeeperContract()
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        guard let passportKey = getPassportKey(passport) else {
            throw "failed to get passport key"
        }
        
        guard let identityKey = getIdentityKey(passport) else {
            throw "failed to get identity key"
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportKey,
            identityKey,
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "proof index is not initialized" }
        
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
            throw "failed to calculate anonymousID"
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
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let stateKeeperContract = try StateKeeperContract()
        
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
        
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        guard let passportKey = getPassportKey(passport) else {
            throw "failed to get passport key"
        }
        
        guard let identityKey = getIdentityKey(passport) else {
            throw "failed to get identity key"
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportKey,
            identityKey,
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "proof index is not initialized" }
        
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
    
    func airdrop(_ queryZkProof: ZkProof) async throws {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let rarimoAddress = profile.getRarimoAddress()
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let _ = try await relayer.airdrop(queryZkProof, to: rarimoAddress)
    }
    
    func isAirdropClaimed() async throws -> Bool {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let airdropParams = try await relayer.getAirdropParams()
        
        var error: NSError? = nil
        let airdropEventNullifier = profile.calculateEventNullifierInt(
            airdropParams.data.attributes.eventID,
            error: &error
        )
        if let error {
            throw error
        }
        
        do {
            let _ = try await relayer.getAirdropInfo(airdropEventNullifier)
        } catch {
            guard let error = error as? AFError else { throw error }
            
            guard case .responseValidationFailed(let errorReason) = error else { throw error }
            
            guard case .customValidationFailed(let validationError) = errorReason else { throw error }
            
            guard let localError = validationError as? Errors else { throw error }
            
            guard case .openAPIErrors(let openApiErrors) = localError else { throw error }
            
            guard let openApiError = openApiErrors.first else { throw error }
            
            if openApiError.status == HTTPStatusCode.notFound.rawValue {
                return false
            }
            
            throw error
        }
        
        return true
    }
    
    func fetchBalanse() async throws -> String {
        let address = self.userAddress
        
        let cosmos = Cosmos(ConfigManager.shared.api.cosmosRpcURL)
        let spendableBalances = try await cosmos.getSpendableBalances(address)
        
        return spendableBalances.balances.first?.amount ?? "0"
    }
    
    func fetchPointsBalance(_ jwt: JWT) async throws -> PointsBalanceRaw {
        let points = Points(ConfigManager.shared.api.pointsServiceURL)
        
        let balanceResponse = try await points.getPointsBalance(jwt, true, true)
        
        return balanceResponse.data.attributes
    }
    
    func sendTokens(_ destination: String, _ amount: String) async throws -> CosmosTransferResponse {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let response = try profile.walletSend(
            destination,
            amount: amount,
            chainID: ConfigManager.shared.cosmos.chainId,
            denom: ConfigManager.shared.cosmos.denom,
            rpcIP: ConfigManager.shared.cosmos.rpcIp
        )
        
        return try JSONDecoder().decode(CosmosTransferResponse.self, from: response)
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
        
        let key = Data(hex: ConfigManager.shared.api.joinRewardsKey) ?? Data()
        
        let hmacSingature = HMACUtils.hmacSha256(hmacMessage ?? Data(), key)
        
        let points = Points(ConfigManager.shared.api.pointsServiceURL)
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
        
        do {
            try AppKeychain.removeValue(.privateKey)
            try AppKeychain.removeValue(.registerZkProof)
            try AppKeychain.removeValue(.passport)
            try AppKeychain.removeValue(.lightRegistrationData)
            
            self.user = nil
            self.balance = 0
            self.registerZkProof = nil
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func generateNullifierForEvent(_ eventId: String) throws -> String {
        guard let user else { throw "User is not initalized" }
        
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
        
        guard let ethereumPrivateKey = try? EthereumPrivateKey(privateKey: user.secretKey.bytes) else {
            return nil
        }
        
        return ethereumPrivateKey.address.hex(eip55: false)
    }
}
