import Foundation
import NFCPassportReader

struct RegisterIdentityCircuitType {
    let signatureType: CircuitSignatureType
    let passportHashType: CircuitPasssportHashType
    let ecChunkNumber: UInt
    let ecDigestPosition: UInt
    let dg1DigestPositionShift: UInt
    let aaType: CircuitAAType?

    func buildName() -> String? {
        var name = "registerIdentity"
        guard let signatureTypeId = signatureType.getId() else {
            return nil
        }
        name += "_\(signatureTypeId)"
        name += "_\(passportHashType.rawValue)"
        name += "_\(ecChunkNumber)"
        name += "_\(ecDigestPosition)"
        name += "_\(dg1DigestPositionShift)"

        if let aaType = aaType {
            name += "_\(aaType.dg15DigestPositionShift)"
            name += "_\(aaType.dg15ChunkNumber)"
            name += "_\(aaType.aaKeyPositionShift)"
        } else {
            name += "_NA"
        }

        return name
    }
}

extension RegisterIdentityCircuitType {
    struct CircuitSignatureType {
        var staticId: UInt
        let algorithm: CircuitSignatureAlgorithmType
        let keySize: CircuitSignatureKeySizeType
        let exponent: CircuitSignatureExponentType?
        let salt: CircuitSignatureSaltType?
        let curve: CircuitSignatureCurveType?
        let hashAlgorithm: CircuitSignatureHashAlgorithmType

        func getId() -> String? {
            return SupportRegisterIdentityCircuitSignatureType.getSupportedSignatureTypeId(self).map { $0.description }
        }
    }

    enum CircuitPasssportHashType: Int {
        case SHA1 = 160
        case SHA2_256 = 256
        case SHA2_384 = 384
        case SHA2_512 = 512
    }

    enum CircuitDocumentType: Int {
        case TD1 = 1
        case TD3 = 3
    }

    struct CircuitAAType {
        let dg15DigestPositionShift: UInt
        let dg15ChunkNumber: UInt
        let aaKeyPositionShift: UInt
    }
}

extension RegisterIdentityCircuitType.CircuitSignatureType {
    enum CircuitSignatureAlgorithmType {
        case RSA, RSAPSS, ECDSA
    }

    enum CircuitSignatureKeySizeType {
        case B2048, B4096, B256, B320, B192
    }

    enum CircuitSignatureExponentType {
        case E3, E65537
    }

    enum CircuitSignatureSaltType {
        case S32, S64, S48
    }

    enum CircuitSignatureCurveType {
        case SECP256R1, BRAINPOOLP256, BRAINPOOL320R1, SECP192R1
    }

    enum CircuitSignatureHashAlgorithmType {
        case HA256, HA384, HA160
    }
}

extension Passport {
    func getRegisterIdentityCircuitType() throws -> RegisterIdentityCircuitType? {
        var sod = try SOD([UInt8](sod))

        let sodSignatureAlgorithmName = try sod.getSignatureAlgorithm()
        guard let sodSignatureAlgorithm = SODSignatureAlgorithm(rawValue: sodSignatureAlgorithmName) else {
            return nil
        }

        let sodPublicKey = try sod.getPublicKey()
        guard let publicKeySize = getSodPublicKeySupportedSize(CryptoUtils.getPublicKeySize(sodPublicKey)) else {
            return nil
        }

        let signatureType = RegisterIdentityCircuitType.CircuitSignatureType(
            staticId: 0,
            algorithm: sodSignatureAlgorithm.getCircuitSignatureAlgorithm(),
            keySize: publicKeySize,
            exponent: getSodPublicKeyExponent(sodPublicKey),
            // TODO: Handle RSAPSS
            salt: nil,
            curve: getSodPublicKeyCurve(sodPublicKey),
            hashAlgorithm: sodSignatureAlgorithm.getCircuitSignatureHashAlgorithm()
        )

        return nil
    }

    private func getSodPublicKeySupportedSize(_ size: Int) -> RegisterIdentityCircuitType.CircuitSignatureType.CircuitSignatureKeySizeType? {
        switch size {
        case 2048:
            return .B2048
        case 4096:
            return .B4096
        case 256:
            return .B256
        case 320:
            return .B320
        case 192:
            return .B192
        default:
            return nil
        }
    }

    private func getSodPublicKeyExponent(_ publicKey: OpaquePointer?) -> RegisterIdentityCircuitType.CircuitSignatureType.CircuitSignatureExponentType? {
        guard let exponent = CryptoUtils.getExponentFromPublicKey(publicKey) else { return nil }

        switch exponent.toUInt() {
        case 3:
            return .E3
        case 65537:
            return .E65537
        default:
            return nil
        }
    }

    private func getSodPublicKeyCurve(_ publicKey: OpaquePointer?) -> RegisterIdentityCircuitType.CircuitSignatureType.CircuitSignatureCurveType? {
        guard let curve = CryptoUtils.getCurveFromECDSAPublicKey(publicKey) else { return nil }

        switch curve {
        case "secp256r1":
            return .SECP256R1
        case "brainpoolP256r1":
            return .BRAINPOOLP256
        case "brainpoolP320r1":
            return .BRAINPOOLP256
        case "secp192r1":
            return .SECP192R1
        default:
            return nil
        }
    }
}
