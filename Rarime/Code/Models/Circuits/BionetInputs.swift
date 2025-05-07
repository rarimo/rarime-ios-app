import Foundation

struct BionetInputs: Codable {
    let image: [[[String]]]
    let features: [String]
    let nonce: String
    let address: String
    let threshold: String
}
