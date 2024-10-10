import Foundation

class SupportRegisterIdentityCircuitAAType {
    static let supported: [RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm] = [
        // RSA
        .init(staticId: 1, algorithm: .RSA, keySize: .B1024, exponent: .E65537, salt: nil, curve: nil, hashAlgorithm: .HA160),

        // ECDSA
        .init(staticId: 20, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .SECP256R1, hashAlgorithm: .HA160),
        .init(staticId: 21, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .BRAINPOOLP256, hashAlgorithm: .HA160),
        .init(staticId: 13, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .SECP192R1, hashAlgorithm: .HA160),
    ]

    static func getSupportedSignatureTypeId(_ type: RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm) -> UInt? {
        supported.first {
            $0.algorithm == type.algorithm &&
                $0.keySize == type.keySize &&
                $0.exponent == type.exponent &&
                $0.salt == type.salt &&
                $0.curve == type.curve &&
                $0.hashAlgorithm == type.hashAlgorithm
        }?.staticId
    }
}
