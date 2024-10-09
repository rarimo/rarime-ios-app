import Foundation

struct RegisterIdentityInputs: Codable {
    let skIdentity: String
    let encapsulatedContent: [Int64]
    let signedAttributes: [Int64]
    let pubkey: [BN]
    let signature: [BN]
    let dg1: [Int64]
    let dg15: [Int64]
    let slaveMerkleRoot: String
    let slaveMerkleInclusionBranches: [String]
}
