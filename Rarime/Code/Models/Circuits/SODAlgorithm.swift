import Foundation

enum SODAlgorithm: String {
    case rsaEncryption
    case sha256WithRSAEncryption
    case rsassaPss
    case ecdsa_with_SHA1
    case ecdsa_with_SHA256

    func getCircuitSignatureAlgorithm() -> RegisterIdentityCircuitType.CircuitAlgorithmType {
        switch self {
        case .rsaEncryption:
            return .RSA
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

    func getCircuitSignatureHashAlgorithm() -> RegisterIdentityCircuitType.CircuitHashAlgorithmType {
        switch self {
        case .rsaEncryption:
            return .HA256
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
