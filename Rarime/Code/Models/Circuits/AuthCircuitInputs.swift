import Foundation

struct AuthCircuitInputs: Codable {
    let skIdentity, eventID, eventData: String
    let revealPkIdentityHash: Int
}
