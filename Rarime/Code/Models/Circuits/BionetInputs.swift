import Foundation

struct BionetInputs: Codable {
    let image: [[[Int]]]
    let features: [Int]
    let nonce: BN
    let address: BN
    let threshold: Int
}
