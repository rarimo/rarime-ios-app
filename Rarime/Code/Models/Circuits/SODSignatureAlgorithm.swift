import Foundation

enum SODSignatureAlgorithm: String {
    case sha256WithRSAEncryption
    case rsassaPss
    case ecdsa_with_SHA1
    case ecdsa_with_SHA256

    func getCircuitSignatureAlgorithm() -> RegisterIdentityCircuitType.CircuitSignatureType.CircuitSignatureAlgorithmType {
        switch self {
        case .sha256WithRSAEncryption:
            return .RSA
        case .rsassaPss:
            return .RSAPSS
        case .ecdsa_with_SHA1:
            return .ECDSA
        case .ecdsa_with_SHA256:
            return .ECDSA
        }
    }

    func getCircuitSignatureHashAlgorithm() -> RegisterIdentityCircuitType.CircuitSignatureType.CircuitSignatureHashAlgorithmType {
        switch self {
        case .sha256WithRSAEncryption:
            return .HA256
        case .rsassaPss:
            return .HA256
        case .ecdsa_with_SHA1:
            return .HA160
        case .ecdsa_with_SHA256:
            return .HA256
        }
    }
}
