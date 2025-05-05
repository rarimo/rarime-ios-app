import Foundation

struct BionetInputs: Codable {
    let image: [[[Int]]]
    let features: [Int]
    let nonce: Int
    let address: Int
    let threshold: Int
}
