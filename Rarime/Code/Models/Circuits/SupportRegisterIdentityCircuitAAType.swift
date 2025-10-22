import Foundation

class SupportRegisterIdentityCircuitAAType {
    static let supported: [RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm] = [
        // RSA
        .init(staticId: 1, algorithm: .RSA, keySize: .B1024, exponent: .E65537, salt: nil, curve: nil, hashAlgorithm: nil),

        // ECDSA
        .init(staticId: 20, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .SECP256R1, hashAlgorithm: .HA160),
        .init(staticId: 21, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .BRAINPOOLP256R1, hashAlgorithm: .HA160),
        .init(staticId: 22, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .BRAINPOOLP320R1, hashAlgorithm: .HA256),
        .init(staticId: 23, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .SECP192R1, hashAlgorithm: .HA160),
        .init(staticId: 24, algorithm: .ECDSA, keySize: nil, exponent: nil, salt: nil, curve: .SECP384R1, hashAlgorithm: .HA384),
    ]

    static func getSupportedSignatureTypeId(_ type: RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm) -> UInt? {
        let result = supported.first {
            $0.algorithm == type.algorithm && $0.hashAlgorithm == type.hashAlgorithm && $0.curve == type.curve
        }?.staticId
        
        if result == nil, type.algorithm == .RSA {
            return 1
        }
        
        return result
    }
}
