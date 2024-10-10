import Foundation
import NFCPassportReader

struct RegisterIdentityCircuitType {
    let signatureType: CircuitSignatureType
    let passportHashType: CircuitPasssportHashType
    let documentType: CircuitDocumentType
    let ecChunkNumber: UInt
    let ecDigestPosition: UInt
    let dg1DigestPositionShift: UInt
    var aaType: CircuitAAType?

    func buildName() -> String? {
        var name = "registerIdentity"
        guard let signatureTypeId = signatureType.getId() else {
            return nil
        }

        name += "_\(signatureTypeId)"
        name += "_\(passportHashType.getId())"
        name += "_\(documentType.getId())"
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

    enum CircuitPasssportHashType: String {
        case sha1
        case sha256
        case sha384
        case sha512

        func getId() -> UInt {
            switch self {
            case .sha1:
                return 160
            case .sha256:
                return 256
            case .sha384:
                return 384
            case .sha512:
                return 512
            }
        }

        func getChunkSize() -> UInt {
            switch self {
            case .sha1:
                return 512
            case .sha256:
                return 512
            case .sha384:
                return 1024
            case .sha512:
                return 1024
            }
        }
    }

    enum CircuitDocumentType: String {
        case TD1
        case TD3

        func getId() -> UInt {
            switch self {
            case .TD1:
                return 1
            case .TD3:
                return 3
            }
        }
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
        let dg1 = try DataGroup1([UInt8](dg1))
        let sod = try SOD([UInt8](sod))

        let sodSignatureAlgorithmName = try sod.getSignatureAlgorithm()
        guard let sodSignatureAlgorithm = SODAlgorithm(rawValue: sodSignatureAlgorithmName) else {
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

        let encapsulatedContentDigestAlgorithm = try sod.getEncapsulatedContentDigestAlgorithm()

        guard let passportHashType = RegisterIdentityCircuitType.CircuitPasssportHashType(rawValue: encapsulatedContentDigestAlgorithm) else {
            return nil
        }

        guard let documentType = RegisterIdentityCircuitType.CircuitDocumentType(rawValue: getStardartalizedDocumentType()) else {
            return nil
        }

        let encapsulatedContent = try sod.getEncapsulatedContent()
        let signedAttributes = try sod.getSignedAttributes()

        let ecChunkNumber = getChunkNumber(encapsulatedContent, passportHashType.getChunkSize())
        let ecHash = try sod.getMessageDigestFromSignedAttributes()

        guard let ecDigestPosition = signedAttributes.findSubarrayIndex(subarray: ecHash) else {
            throw "Unable to find EC digest position"
        }

        let dg1Hash = Data(dg1.hash(passportHashType.rawValue.uppercased()))
        guard let dg1DigestPositionShift = encapsulatedContent.findSubarrayIndex(subarray: dg1Hash) else {
            throw "Unable to find DG1 digest position"
        }

        var circuitType = RegisterIdentityCircuitType(
            signatureType: signatureType,
            passportHashType: passportHashType,
            documentType: documentType,
            ecChunkNumber: ecChunkNumber,
            ecDigestPosition: ecDigestPosition * 8,
            dg1DigestPositionShift: dg1DigestPositionShift * 8,
            aaType: nil
        )

        if !dg15.isEmpty {
            let dg15Wrapper = try DataGroup15([UInt8](dg15))

            let dg15Hash = Data(dg15Wrapper.hash(passportHashType.rawValue.uppercased()))

            guard let dg15DigestPositionShift = encapsulatedContent.findSubarrayIndex(subarray: dg15Hash) else {
                throw "Unable to find DG15 digest position"
            }

            let dg15ChunkNumber = getChunkNumber(dg15, passportHashType.getChunkSize())

            var pubkeyData: Data
            if let rsaPublicKey = dg15Wrapper.rsaPublicKey {
                pubkeyData = CryptoUtils.getModulusFromRSAPublicKey(rsaPublicKey) ?? Data()
            } else if let ecdsa = dg15Wrapper.ecdsaPublicKey {
                pubkeyData = CryptoUtils.getXYFromECDSAPublicKey(ecdsa) ?? Data()
            } else {
                throw "Unable to find public key"
            }

            guard let aaKeyPositionShift = dg15.findSubarrayIndex(subarray: pubkeyData) else {
                throw "Unable to find AA key position"
            }

            circuitType.aaType = RegisterIdentityCircuitType.CircuitAAType(
                dg15DigestPositionShift: dg15DigestPositionShift * 8,
                dg15ChunkNumber: dg15ChunkNumber,
                aaKeyPositionShift: aaKeyPositionShift * 8
            )
        }

        return circuitType
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

        let exponentBN = BN(exponent)

        if exponentBN.cmp(BN(3)) == 0 {
            return .E3
        } else if exponentBN.cmp(BN(65537)) == 0 {
            return .E65537
        } else {
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

    private func getChunkNumber(_ data: Data, _ chunkSize: UInt) -> UInt {
        let length = UInt(data.count) * 8 + 1 + 64

        return length / chunkSize + (length % chunkSize == 0 ? 0 : 1)
    }
}
