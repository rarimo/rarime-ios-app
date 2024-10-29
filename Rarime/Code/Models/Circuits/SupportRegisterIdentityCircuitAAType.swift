import Foundation

class SupportRegisterIdentityCircuitAAType {
    static let supported: [RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm] = [
        // RSA
        .init(staticId: 1, algorithm: .RSA, keySize: nil, exponent: nil, salt: nil, curve: nil, hashAlgorithm: .HA160),

        // ECDSA
        .init(staticId: 21, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: nil, hashAlgorithm: .HA160),
    ]

    static func getSupportedSignatureTypeId(_ type: RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm) -> UInt? {
        supported.first {
            $0.algorithm == type.algorithm && $0.hashAlgorithm == type.hashAlgorithm
        }?.staticId
    }
}
