import Foundation

typealias PubSignals = [String]

struct Proof: Codable {
    let piA: [String]
    let piB: [[String]]
    let piC: [String]
    let proofProtocol: String

    enum CodingKeys: String, CodingKey {
        case piA = "pi_a"
        case piB = "pi_b"
        case piC = "pi_c"
        case proofProtocol = "protocol"
    }
}

struct ZkProof: Codable {
    let proof: Proof
    let pubSignals: PubSignals

    enum CodingKeys: String, CodingKey {
        case proof
        case pubSignals = "pub_signals"
    }
}
