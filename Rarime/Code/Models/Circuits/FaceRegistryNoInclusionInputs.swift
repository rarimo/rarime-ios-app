import Foundation

struct FaceRegistryNoInclusionInputs: Codable {
    let eventId: String
    let nonce: String
    let value: String
    let skIdentity: String

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case nonce
        case value
        case skIdentity = "sk_identity"
    }
}
