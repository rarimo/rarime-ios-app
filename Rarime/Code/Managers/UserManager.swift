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
    
    @Published var masterCertProof: SMTProof?
    
    @Published var balance: Double
    
    @Published var isRevoked: Bool
    
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
                }
                
                AppUserDefaults.shared.isFirstLaunch = false
            }
            
            self.user = try User.load()
            self.balance = 0
            self.isRevoked = AppUserDefaults.shared.isUserRevoked
            
            if let registerZkProofJson = try AppKeychain.getValue(.registerZkProof) {
                let registerZkProof = try JSONDecoder().decode(ZkProof.self, from: registerZkProofJson)
                
                self.registerZkProof = registerZkProof
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
    
    var userAddress: String {
        self.user?.profile.getRarimoAddress() ?? "undefined"
    }
    
    var userChallenge: Data {
        (try? self.user?.profile.getRegistrationChallenge()) ?? Data()
    }
    
    func generateRegisterIdentityProof(
        _ inputs: Data,
        _ circuitData: CircuitData,
        _ registeredCircuitData: RegisteredCircuitData
    ) throws -> ZkProof? {
        var wtns: Data
        switch registeredCircuitData {
        case .registerIdentity_1_256_3_5_576_248_NA:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_1_256_3_5_576_248_NA(circuitData.circutDat, inputs)
        case .registerIdentity_1_256_3_6_576_248_1_2432_5_296:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_1_256_3_6_576_248_1_2432_5_296(circuitData.circutDat, inputs)
        case .registerIdentity_2_256_3_6_336_264_21_2448_6_2008:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_2_256_3_6_336_264_21_2448_6_2008(circuitData.circutDat, inputs)
        case .registerIdentity_21_256_3_7_336_264_21_3072_6_2008:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_21_256_3_7_336_264_21_3072_6_2008(circuitData.circutDat, inputs)
        case .registerIdentity_1_256_3_6_576_264_1_2448_3_256:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_1_256_3_6_576_264_1_2448_3_256(circuitData.circutDat, inputs)
        case .registerIdentity_2_256_3_6_336_248_1_2432_3_256:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_2_256_3_6_336_248_1_2432_3_256(circuitData.circutDat, inputs)
        case .registerIdentity_2_256_3_6_576_248_1_2432_3_256:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_2_256_3_6_576_248_1_2432_3_256(circuitData.circutDat, inputs)
        case .registerIdentity_11_256_3_3_576_248_1_1184_5_264:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_11_256_3_3_576_248_1_1184_5_264(circuitData.circutDat, inputs)
        case .registerIdentity_12_256_3_3_336_232_NA:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_12_256_3_3_336_232_NA(circuitData.circutDat, inputs)
        case .registerIdentity_1_256_3_4_336_232_1_1480_5_296:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_1_256_3_4_336_232_1_1480_5_296(circuitData.circutDat, inputs)
        case .registerIdentity_1_256_3_4_600_248_1_1496_3_256:
            wtns = try ZKUtils.calcWtnsRegisterIdentity_1_256_3_4_600_248_1_1496_3_256(circuitData.circutDat, inputs)
        }
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(circuitData.circuitZkey, wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func register(_ registerZkProof: ZkProof, _ passport: Passport, _ isRevoked: Bool, _ registerIdentityCircuitName: String) async throws {
        let slaveCertPem = try passport.getSlaveSodCertificatePem()
        
        let masterCertProof = try await passport.getCertificateSmtProof(slaveCertPem)
        
        let proofJson = try JSONEncoder().encode(registerZkProof)
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRegisterCalldata(
            proofJson,
            signature: passport.signature,
            pubKeyPem: passport.getDG15PublicKeyPEM(),
            certificatesRootRaw: masterCertProof.root,
            isRevoked: isRevoked,
            circuitName: registerIdentityCircuitName
        )
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.api.registerContractAddress)
        
        LoggerUtil.common.info("Passport register EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func revoke(_ passportInfo: PassportInfo, _ passport: Passport) async throws {
        let identityKey = passportInfo.activeIdentity
        
        let signature = passport.signature
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRevoceCalldata(
            identityKey,
            signature: signature,
            pubKeyPem: passport.getDG15PublicKeyPEM()
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
        
        let calldata = try IdentityCallDataBuilder().buildRegisterCertificateCalldata(
            ConfigManager.shared.certificatesStorage.icaoCosmosRpc,
            slavePem: certPem,
            masterCertificatesBucketname: ConfigManager.shared.certificatesStorage.masterCertificatesBucketname,
            masterCertificatesFilename: ConfigManager.shared.certificatesStorage.masterCertificatesFilename
        )
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata, ConfigManager.shared.api.registerContractAddress)
        
        LoggerUtil.common.info("Register certificate EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func generateAirdropQueryProof(_ registerZkProof: ZkProof, _ passport: Passport) async throws -> ZkProof {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let stateKeeperContract = try StateKeeperContract()
        
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
        
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        let passportInfoKey: String
        if passport.dg15.isEmpty {
            passportInfoKey = registerZkProof.pubSignals[1]
        } else {
            passportInfoKey = registerZkProof.pubSignals[0]
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportInfoKey,
            registerZkProof.pubSignals[3],
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "proof index is not initialized" }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let aidropParams = try await relayer.getAirdropParams()

        let queryProofInputs = try profile.buildAirdropQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: aidropParams.data.attributes.querySelector,
            pkPassportHash: passportInfoKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: aidropParams.data.attributes.eventID,
            startedAt: Int64(aidropParams.data.attributes.startedAt)
        )
        
        let wtns = try ZKUtils.calcWtnsQueryIdentity(queryProofInputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func generateQueryProof(
        passport: Passport,
        params: GetProofParamsResponseAttributes
    ) async throws -> ZkProof {
        guard let registerZkProof = self.registerZkProof else { throw "failed to get registerZkProof" }
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let stateKeeperContract = try StateKeeperContract()
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        let passportInfoKey: String
        if passport.dg15.isEmpty {
            passportInfoKey = registerZkProof.pubSignals[1]
        } else {
            passportInfoKey = registerZkProof.pubSignals[0]
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportInfoKey,
            registerZkProof.pubSignals[3],
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "proof index is not initialized" }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
        let queryProofInputs = try profile.buildQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: params.selector,
            pkPassportHash: passportInfoKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: params.eventID,
            eventData: params.eventData,
            timestampLowerbound: params.timestampLowerBound,
            timestampUpperbound: max(
                UInt64(params.timestampUpperBound),
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
        
        let wtns = try ZKUtils.calcWtnsQueryIdentity(queryProofInputs)
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func collectPubSignals(
        passport: Passport,
        params: GetProofParamsResponseAttributes
    ) throws -> PubSignals {
        let nullifier = try generateNullifierForEvent(params.eventID)
        let currentTimestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        
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
            "0",
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
    
    func generatePointsProof(_ registerZkProof: ZkProof, _ passport: Passport) async throws -> ZkProof {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let stateKeeperContract = try StateKeeperContract()
        
        let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
        
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
        
        let passportInfoKey: String
        if passport.dg15.isEmpty {
            passportInfoKey = registerZkProof.pubSignals[1]
        } else {
            passportInfoKey = registerZkProof.pubSignals[0]
        }
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            passportInfoKey,
            registerZkProof.pubSignals[3],
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "proof index is not initialized" }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
        
        let queryProofInputs = try profile.buildAirdropQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: "23073",
            pkPassportHash: passportInfoKey,
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            eventID: Points.PointsEventId,
            startedAt: 1715688000
        )
        
        let wtns = try ZKUtils.calcWtnsQueryIdentity(queryProofInputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
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
    
    func reserveTokens(_ jwt: JWT, _ registerProof: ZkProof, _ passport: Passport) async throws {
        let queryProof = try await generatePointsProof(registerProof, passport)
        
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
}
