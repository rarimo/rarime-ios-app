import Foundation

typealias GrothZkProofPubSignals = [String]

struct GrothZkProofPoints: Codable {
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

struct GrothZkProof: Codable {
    let proof: GrothZkProofPoints
    let pubSignals: GrothZkProofPubSignals

    enum CodingKeys: String, CodingKey {
        case proof
        case pubSignals = "pub_signals"
    }
}

enum ZkProof: Codable {
    case groth(GrothZkProof)
    case plonk(Data)

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .groth(let proof):
            try container.encode(proof)
        case .plonk(let proof):
            try container.encode(proof)
        }
    }
}
