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

struct RegisterContestantInputs: Codable {
    let encapsulatedContent: [Int64]
    let dg1: [Int64]
    let dg2Hash: [Int64]
    let idStateSiblings: [String]
    let timestamp: String
    let identityCounter: String
    let skIdentity: String
    let pkPassportHash: String
    let idStateRoot: String
}
