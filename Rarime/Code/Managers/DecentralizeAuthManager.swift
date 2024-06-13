import Identity
import Foundation

class DecentralizeAuthManager {
    static let AuthEventId = "0x77fabbc6cb41a11d4fb6918696b3550d5d602f252436dd587f9065b7c4e62b"
    
    static let shared = DecentralizeAuthManager()
    
    let authorize: Authorize
    
    var accessJwt: Optional<JWT> = nil
    var refreshJwt: Optional<JWT> = nil
    
    init() {
        self.authorize = Authorize(ConfigManager.shared.api.authorizeURL)
    }
    
    func initializeJWT(_ secretKey: Data) async throws {
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        var error: NSError?
        let nullifier = profile.calculateEventNullifierHex(DecentralizeAuthManager.AuthEventId, error: &error)
        if let error {
            throw error
        }
        
        let requestChallengeResponse = try await authorize.requestChallenge(nullifier)
        
        let authCircuitInputs = AuthCircuitInputs(
            skIdentity: secretKey.hex,
            eventID: DecentralizeAuthManager.AuthEventId,
            eventData: requestChallengeResponse.data.attributes.challenge,
            revealPkIdentityHash: 0
        )
        
        let privateInputsJson = try JSONEncoder().encode(authCircuitInputs)
        
        let wtns = try ZKUtils.calcWtnsAuth(privateInputsJson)
        
        let (proofJson, pubSignalsJson) = try ZKUtils.groth16Auth(wtns)
        
        let proof = try JSONDecoder.init().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder.init().decode(PubSignals.self, from: pubSignalsJson)
        
        let zkProof = ZkProof(proof: proof, pubSignals: pubSignals)
        
        let authorizeUserResponse = try await self.authorize.authorizeUser(zkProof)
        
        self.accessJwt = try JWT(authorizeUserResponse.data.attributes.accessToken.token)
        self.refreshJwt = try JWT(authorizeUserResponse.data.attributes.refreshToken.token)
    }
    
    func refreshIfNeeded(_ secretKey: Data) async throws {
        guard let refreshJwt = self.refreshJwt else {
            return
        }
        
        if !refreshJwt.isExpiringIn5Minutes {
            return
        }
        
        let profileInitializer = IdentityProfile()
        let profile = try profileInitializer.newProfile(secretKey)
        
        var error: NSError?
        let nullifier = profile.calculateEventNullifierHex(DecentralizeAuthManager.AuthEventId, error: &error)
        if let error {
            throw error
        }
        
        let refreshJwtReponse = try await authorize.refreshJwt(refreshJwt.raw)
        
        self.accessJwt = try JWT(refreshJwtReponse.data.attributes.accessToken.token)
        self.refreshJwt = try JWT(refreshJwtReponse.data.attributes.refreshToken.token)
    }
}
