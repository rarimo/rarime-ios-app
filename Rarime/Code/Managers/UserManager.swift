import SwiftUI
import Identity
import NFCPassportReader

private let ENCAPSULATED_CONTENT_2688: Int = 2688
private let ENCAPSULATED_CONTENT_2704: Int = 2704

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var user: User?
    
    @Published var registerZkProof: ZkProof?
    
    @Published var balance: Double
    
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
            
            if let registerZkProofJson = try AppKeychain.getValue(.registerZkProof) {
                let registerZkProof = try JSONDecoder().decode(ZkProof.self, from: registerZkProofJson)
                
                self.registerZkProof = registerZkProof
            }
        } catch {
            fatalError("\(error)")
        }
    }
    
    func createNewUser() throws {
        guard let secretKey = IdentityNewBJJSecretKey() else { throw "failed to create new secret key" }
        
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
    
    func buildRegistrationCircuits(_ passport: Passport) throws -> Data {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }

        let sod = try SOD([UInt8](passport.sod))
        
        let encapsulatedContent = try sod.getEncapsulatedContent()
        let signedAttributes = try sod.getSignedAttributes()
        
        let publicKey = try sod.getPublicKey()
        let publicKeyPem = OpenSSLUtils.pubKeyToPEM(pubKey: publicKey)
        
        let signature = try sod.getSignature()
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let inputs = try profile.buildRegisterIdentityInputs(
            encapsulatedContent,
            signedAttributes: signedAttributes,
            dg1: passport.dg1,
            dg15: passport.dg15,
            pubKeyPem: publicKeyPem.data(using: .utf8) ?? Data(),
            signature: signature
        )
        
        return inputs
    }
    
    func generateRegisterIdentityProof(_ passport: Passport) async throws -> ZkProof? {
        let inputs = try buildRegistrationCircuits(passport)
        
        let encapsulatedContentSize = passport.encapsulatedContentSize
        
        guard let curcuitData = try CircuitDataManager.shared.getRegisterIdentityCircuitData(encapsulatedContentSize) else {
            return nil
        }
        
        let wtns: Data? = try {
            switch encapsulatedContentSize {
            case ENCAPSULATED_CONTENT_2688:
                return try ZKUtils.calcWtnsRegisterIdentity2688(inputs, curcuitData.circutDat)
            case ENCAPSULATED_CONTENT_2704:
                return try ZKUtils.calcWtnsRegisterIdentity2704(inputs, curcuitData.circutDat)
            default:
                return nil
            }
        }()
        
        guard let wtns else { throw "unknown encapsulatedContentSize: \(encapsulatedContentSize)" }
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Prover(curcuitData.circuitZkey, wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func register(_ registerZkProof: ZkProof, _ passport: Passport) async throws {
        let proofJson = try JSONEncoder().encode(registerZkProof)
        
        let sod = try DataGroup15([UInt8](passport.dg15))
        
        guard let pubkey = sod.rsaPublicKey else { throw "Public key is missing" }
        
        let pubKeyPem = OpenSSLUtils.pubKeyToPEM(pubKey: pubkey).data(using: .utf8)
        
        let calldataBuilder = IdentityCallDataBuilder()
        
        let calldata = try calldataBuilder.buildRegisterCalldata(
            proofJson,
            signature: passport.signature,
            pubKeyPem: pubKeyPem,
            encapsulatedContentSize: passport.encapsulatedContentSize
        )
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        
        let _ = try await relayer.register(calldata)
    }
    
    func generateAirdropQueryProof(_ registerZkProof: ZkProof, _ passport: Passport) async throws -> ZkProof {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let registrationContract = try RegistrationContract()
        
        let smtProof = try await registrationContract.getProof(
            registerZkProof.pubSignals[0],
            registerZkProof.pubSignals[2]
        )
        
        let smtProofJson = try JSONEncoder().encode(smtProof)
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let (passportInfo, identityInfo) = try await registrationContract.getPassportInfo(registerZkProof.pubSignals[0])
        
        let queryProofInputs = try profile.buildQueryIdentityInputs(
            passport.dg1,
            smtProofJSON: smtProofJson,
            selector: "39",
            pkPassportHash: registerZkProof.pubSignals[0],
            issueTimestamp: identityInfo.issueTimestamp.description,
            identityCounter: passportInfo.identityReissueCounter.description,
            timestampLowerbound: "0",
            timestampUpperbound: "0",
            identityCounterLowerbound: "1",
            identityCounterUpperbound: "0"
        )
        
        let wtns = try ZKUtils.calcWtnsQueryIdentity(queryProofInputs)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16QueryIdentity(wtns)
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        return ZkProof(proof: proof, pubSignals: pubSignals)
    }
    
    func airDrop(_ queryZkProof: ZkProof) async throws {
        guard let secretKey = self.user?.secretKey else { throw "Secret Key is not initialized" }
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        let rarimoAddress = profile.getRarimoAddress()
        
        let relayer = Relayer(ConfigManager.shared.api.relayerURL)
        let _ = try await relayer.airdrop(queryZkProof, to: rarimoAddress)
    }
    
    func fetchBalanse() async throws -> String {
        let address = userAddress
        
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
}
