import Foundation
import Identity
import Semaphore

class DecentralizedAuthManager: ObservableObject {
    static let AuthEventId = "0x77fabbc6cb41a11d4fb6918696b3550d5d602f252436dd587f9065b7c4e62b"
    
    static let shared = DecentralizedAuthManager()
    
    let authorize: AuthorizeService
    
    var accessJwt: JWT? = nil
    var refreshJwt: JWT? = nil
    
    private let semaphore = AsyncSemaphore(value: 1)
    
    init() {
        self.authorize = AuthorizeService(ConfigManager.shared.api.authorizeURL)
    }
    
    func initializeJWT(_ secretKey: Data) async throws {
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
        
        let proof = try JSONDecoder().decode(Proof.self, from: proofJson)
        let pubSignals = try JSONDecoder().decode(PubSignals.self, from: pubSignalsJson)
        
        let zkProof = ZkProof(proof: proof, pubSignals: pubSignals)
        
        let authorizeUserResponse = try await authorize.authorizeUser(nullifier, zkProof)
        
        let accessJwt = try JWT(authorizeUserResponse.data.attributes.accessToken.token)
        let refreshJwt = try JWT(authorizeUserResponse.data.attributes.refreshToken.token)
        
        self.accessJwt = accessJwt
        self.refreshJwt = refreshJwt
    }
    
    func refreshIfNeeded(_ secretKey: Data) async throws {
        guard let refreshJwt = refreshJwt else { return }
        guard let accessJwt = accessJwt else { return }
        
        if accessJwt.isExpired && refreshJwt.isExpired {
            reset()
            try await initializeJWT(secretKey)
            
            return
        }
        
        if !accessJwt.isExpiringSoon {
            return
        }
        
        let refreshJwtReponse = try await authorize.refreshJwt(refreshJwt.raw)
        
        let newAccessJwt = try JWT(refreshJwtReponse.data.attributes.accessToken.token)
        let newRefreshJwt = try JWT(refreshJwtReponse.data.attributes.refreshToken.token)

        self.accessJwt = newAccessJwt
        self.refreshJwt = newRefreshJwt
    }
    
    func getAccessJwt(_ user: User) async throws -> JWT {
        await semaphore.wait()
        defer { semaphore.signal() }
        
        if self.accessJwt == nil && self.refreshJwt == nil {
            try await self.initializeJWT(user.secretKey)
        } else {
            try await self.refreshIfNeeded(user.secretKey)
        }

        guard let accessJwt = self.accessJwt else { throw "accessJwt is nil" }
        
        return accessJwt
    }
    
    func reset() {
        self.accessJwt = nil
        self.refreshJwt = nil
    }
}
