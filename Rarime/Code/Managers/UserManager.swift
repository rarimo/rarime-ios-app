import Alamofire
import Identity
import NFCPassportReader
import SwiftUI

private let ENCAPSULATED_CONTENT_2688: Int = 2688
private let ENCAPSULATED_CONTENT_2704: Int = 2704

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var user: User?
    
    @Published var registerZkProof: ZkProof?
    
    @Published var masterCertProof: SMTProof?
    
    @Published var balance: Double
    @Published var reservedBalance: Double
    @Published var isPassportTokensReserved: Bool
    
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
            self.reservedBalance = AppUserDefaults.shared.reservedBalance
            self.isPassportTokensReserved = AppUserDefaults.shared.isPassportTokensReserved
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
    
    func buildRegistrationCircuits(_ passport: Passport) async throws -> Data {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }

        let sod = try SOD([UInt8](passport.sod))
        let dg15 = try DataGroup15([UInt8](passport.dg15))
        
        guard let cert = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.pkcs7CertificateData)).first else {
            throw "Slave certificate in sod is missing"
        }
        
        let certPem = cert.certToPEM().data(using: .utf8) ?? Data()
        
        let registrationContract = try RegistrationContract()
        
        let certificatesSMTAddress = try await registrationContract.certificatesSmt()
        
        let certificatesSMTContract = try PoseidonSMT(contractAddress: certificatesSMTAddress)
        
        let x509Utils = IdentityX509Util()
        
        let slaveCertificateIndex = try x509Utils.getSlaveCertificateIndex(certPem, mastersPem: Certificates.ICAO)
        
        let certificateProof = try await certificatesSMTContract.getProof(slaveCertificateIndex)
        
        let encapsulatedContent = try sod.getEncapsulatedContent()
        let signedAttributes = try sod.getSignedAttributes()
        
        let publicKey = try sod.getPublicKey()
        let publicKeyPem = OpenSSLUtils.pubKeyToPEM(pubKey: publicKey)
        
        let signature = try sod.getSignature()
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let isEcdsaActiveAuthentication: Bool = dg15.ecdsaPublicKey != nil
        
        let inputs = try profile.buildRegisterIdentityInputs(
            encapsulatedContent,
            signedAttributes: signedAttributes,
            dg1: passport.dg1,
            dg15: passport.dg15,
            pubKeyPem: publicKeyPem.data(using: .utf8) ?? Data(),
            signature: signature,
            isEcdsaActiveAuthentication: isEcdsaActiveAuthentication,
            certificatesSMTProofJSON: JSONEncoder().encode(certificateProof)
        )
        
        DispatchQueue.main.async { self.masterCertProof = certificateProof }
        
        return inputs
    }
    
    func generateRegisterIdentityProof(_ passport: Passport) async throws -> ZkProof? {
        let inputs = try await buildRegistrationCircuits(passport)
        
        let wtns = try ZKUtils.calcWtnsRegisterIdentityUniversal(inputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16RegisterIdentityUniversal(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func register(_ registerZkProof: ZkProof, _ passport: Passport, _ isRevoked: Bool) async throws {
        guard let masterCertProof = self.masterCertProof else { throw "Master certificate proof is missing" }
        
        let proofJson = try JSONEncoder().encode(registerZkProof)
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRegisterCalldata(
            proofJson,
            signature: passport.signature,
            pubKeyPem: passport.getDG15PublicKeyPEM(),
            certificatesRootRaw: masterCertProof.root,
            isRevoced: isRevoked
        )
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata)
        
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
        let response = try await relayer.register(calldata)
        
        LoggerUtil.common.info("Passport revoke EVM Tx Hash: \(response.data.attributes.txHash, privacy: .public)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func registerCertificate(_ passport: Passport) async throws {
        let sod = try SOD([UInt8](passport.sod))
        
        guard let cert = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.pkcs7CertificateData)).first else {
            throw "Slave certificate in sod is missing"
        }
        
        let certPem = cert.certToPEM().data(using: .utf8) ?? Data()
        
        let registrationContract = try RegistrationContract()

        let certificatesSMTAddress = try await registrationContract.certificatesSmt()
        
        let certificatesSMTContract = try PoseidonSMT(contractAddress: certificatesSMTAddress)
        
        let x509Utils = IdentityX509Util()
        
        let slaveCertificateIndex = try x509Utils.getSlaveCertificateIndex(certPem, mastersPem: Certificates.ICAO)
        
        let proof = try await certificatesSMTContract.getProof(slaveCertificateIndex)
        
        if proof.existence {
            LoggerUtil.common.info("Passport certificate is already registered")
            
            return
        }
        
        let calldataBuilder = IdentityCallDataBuilder()
        let calldata = try calldataBuilder.buildRegisterCertificateCalldata(
            ConfigManager.shared.certificatesStorage.icaoCosmosRpc,
            slavePem: certPem,
            masterCertificatesBucketname: ConfigManager.shared.certificatesStorage.masterCertificatesBucketname,
            masterCertificatesFilename: ConfigManager.shared.certificatesStorage.masterCertificatesFilename
        )
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let response = try await relayer.register(calldata)
        
        LoggerUtil.common.info("Register certificate EVM Tx Hash: \(response.data.attributes.txHash)")
        
        let eth = Ethereum()
        try await eth.waitForTxSuccess(response.data.attributes.txHash)
    }
    
    func generateAirdropQueryProof(_ registerZkProof: ZkProof, _ passport: Passport) async throws -> ZkProof {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let registrationContract = try RegistrationContract()
        
        let registrationSmtEvmAddress = try await registrationContract.registrationSmt()
        
        let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtEvmAddress)
        
        var error: NSError? = nil
        let proofIndex = IdentityCalculateProofIndex(
            registerZkProof.pubSignals[0],
            registerZkProof.pubSignals[2],
            &error
        )
        if let error { throw error }
        guard let proofIndex else { throw "proof index is not initialized" }
        
        let smtProof = try await registrationSmtContract.getProof(proofIndex)
        
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await registrationContract.getPassportInfo(registerZkProof.pubSignals[0])
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let aidropParams = try await relayer.getAirdropParams()

        let queryProofInputs = try profile.buildAirdropQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: aidropParams.data.attributes.querySelector,
            pkPassportHash: registerZkProof.pubSignals[0],
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
        let airdropEventNullifier = profile.calculateAirdropEventNullifier(
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
    
    func reserveTokens() async throws {
        // TODO: implement reserve tokens
        try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
        
        self.reservedBalance = PASSPORT_RESERVE_TOKENS
        self.isPassportTokensReserved = true

        AppUserDefaults.shared.reservedBalance = PASSPORT_RESERVE_TOKENS
        AppUserDefaults.shared.isPassportTokensReserved = true
    }
    
    func reset() {
        AppUserDefaults.shared.reservedBalance = 0.0
        AppUserDefaults.shared.isPassportTokensReserved = false
        AppUserDefaults.shared.isUserRevoked = false
        
        do {
            try AppKeychain.removeValue(.privateKey)
            try AppKeychain.removeValue(.registerZkProof)
            try AppKeychain.removeValue(.passport)
            
            self.user = try User.load()
            self.balance = 0
            self.reservedBalance = AppUserDefaults.shared.reservedBalance
            self.isPassportTokensReserved = AppUserDefaults.shared.isPassportTokensReserved
            
            if let registerZkProofJson = try AppKeychain.getValue(.registerZkProof) {
                self.registerZkProof = try JSONDecoder().decode(ZkProof.self, from: registerZkProofJson)
            }
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
}
