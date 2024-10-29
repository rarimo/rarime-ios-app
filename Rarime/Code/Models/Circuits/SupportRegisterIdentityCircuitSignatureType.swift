import Foundation

class SupportRegisterIdentityCircuitSignatureType {
    static let supported: [RegisterIdentityCircuitType.CircuitSignatureType] = [
        // RSA
        .init(staticId: 1, algorithm: .RSA, keySize: .B2048, exponent: .E65537, salt: nil, curve: nil, hashAlgorithm: .HA256),
        .init(staticId: 2, algorithm: .RSA, keySize: .B4096, exponent: .E65537, salt: nil, curve: nil, hashAlgorithm: .HA256),

        // RSAPSS
        .init(staticId: 10, algorithm: .RSAPSS, keySize: .B2048, exponent: .E3, salt: .S32, curve: nil, hashAlgorithm: .HA256),
        .init(staticId: 11, algorithm: .RSAPSS, keySize: .B2048, exponent: .E65537, salt: .S32, curve: nil, hashAlgorithm: .HA256),
        .init(staticId: 12, algorithm: .RSAPSS, keySize: .B2048, exponent: .E65537, salt: .S64, curve: nil, hashAlgorithm: .HA256),
        .init(staticId: 13, algorithm: .RSAPSS, keySize: .B2048, exponent: .E65537, salt: .S48, curve: nil, hashAlgorithm: .HA384),

        // ECDSA
        .init(staticId: 20, algorithm: .ECDSA, keySize: .B256, exponent: nil, salt: nil, curve: .SECP256R1, hashAlgorithm: .HA256),
        .init(staticId: 21, algorithm: .ECDSA, keySize: .B256, exponent: nil, salt: nil, curve: .BRAINPOOLP256, hashAlgorithm: .HA256),
        .init(staticId: 22, algorithm: .ECDSA, keySize: .B320, exponent: nil, salt: nil, curve: .BRAINPOOL320R1, hashAlgorithm: .HA256),
        .init(staticId: 22, algorithm: .ECDSA, keySize: .B192, exponent: nil, salt: nil, curve: .SECP192R1, hashAlgorithm: .HA160),
    ]

    static func getSupportedSignatureTypeId(_ type: RegisterIdentityCircuitType.CircuitSignatureType) -> UInt? {
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
