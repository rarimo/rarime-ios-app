import Identity
import Foundation
import Semaphore

class DecentralizedAuthManager: ObservableObject {
    static let AuthEventId = "0x77fabbc6cb41a11d4fb6918696b3550d5d602f252436dd587f9065b7c4e62b"
    
    static let shared = DecentralizedAuthManager()
    
    let authorize: AuthorizeService
    
    @Published var accessJwt: Optional<JWT> = nil
    @Published var refreshJwt: Optional<JWT> = nil
    
    private let semaphore = AsyncSemaphore(value: 1)
    
    init() {
        self.authorize = AuthorizeService(ConfigManager.shared.api.authorizeURL)
    }
    
    func initializeJWT(_ secretKey: Data) async throws {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        if accessJwt != nil {
            return
        }
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        var error: NSError?
        let nullifier = profile.calculateEventNullifierHex(DecentralizedAuthManager.AuthEventId, error: &error)
        if let error {
            throw error
        }
        
        let requestChallengeResponse = try await authorize.requestChallenge(nullifier)
        
        let authCircuitInputs = AuthCircuitInputs(
            skIdentity: secretKey.fullHex,
            eventID: DecentralizedAuthManager.AuthEventId,
            eventData: requestChallengeResponse.data.attributes.challenge.fullHex,
            revealPkIdentityHash: 0
        )
        
        let privateInputsJson = try JSONEncoder().encode(authCircuitInputs)
        
        let wtns = try ZKUtils.calcWtnsAuth(privateInputsJson)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Auth(wtns)
        
        let proof = try JSONDecoder.init().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder.init().decode(PubSignals.self, from: pubSignalsJson)
        
        let zkProof = ZkProof(proof: proof, pubSignals: pubSignals)
        
        let authorizeUserResponse = try await self.authorize.authorizeUser(nullifier, zkProof)
        
        let accessJwt = try JWT(authorizeUserResponse.data.attributes.accessToken.token)
        let refreshJwt = try JWT(authorizeUserResponse.data.attributes.refreshToken.token)
        
        DispatchQueue.main.async {
            self.accessJwt = accessJwt
            self.refreshJwt = refreshJwt
        }
    }
    
    func refreshIfNeeded() async throws {
        guard let refreshJwt = self.refreshJwt else {
            return
        }
        
        if !refreshJwt.isExpiringSoon {
            return
        }
        
        let refreshJwtReponse = try await authorize.refreshJwt(refreshJwt.raw)
        
        self.accessJwt = try JWT(refreshJwtReponse.data.attributes.accessToken.token)
        self.refreshJwt = try JWT(refreshJwtReponse.data.attributes.refreshToken.token)
    }
}