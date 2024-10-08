import Foundation

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
        let hashAlgorithm: CircuitSignatureHashAlgorithmType?

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
