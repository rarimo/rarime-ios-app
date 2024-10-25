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
            guard let aaTypeId = aaType.aaAlgorithm.getId() else {
                return nil
            }

            name += "_\(aaTypeId)"
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
        let algorithm: CircuitAlgorithmType
        let keySize: CircuitKeySizeType
        let exponent: CircuitExponentType?
        let salt: CircuitSaltType?
        let curve: CircuitCurveType?
        let hashAlgorithm: CircuitHashAlgorithmType

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
        let aaAlgorithm: CircuitAAAlgorithm
        let dg15DigestPositionShift: UInt
        let dg15ChunkNumber: UInt
        let aaKeyPositionShift: UInt
    }
}

extension RegisterIdentityCircuitType.CircuitAAType {
    struct CircuitAAAlgorithm {
        var staticId: UInt
        let algorithm: RegisterIdentityCircuitType.CircuitAlgorithmType
        let keySize: RegisterIdentityCircuitType.CircuitKeySizeType?
        let exponent: RegisterIdentityCircuitType.CircuitExponentType?
        let salt: RegisterIdentityCircuitType.CircuitSaltType?
        let curve: RegisterIdentityCircuitType.CircuitCurveType?
        let hashAlgorithm: RegisterIdentityCircuitType.CircuitHashAlgorithmType

        func getId() -> String? {
            return SupportRegisterIdentityCircuitAAType.getSupportedSignatureTypeId(self).map { $0.description }
        }
    }
}

extension RegisterIdentityCircuitType {
    enum CircuitAlgorithmType {
        case RSA, RSAPSS, ECDSA
    }

    enum CircuitKeySizeType {
        case B1024, B2048, B4096, B256, B320, B192
    }

    enum CircuitExponentType {
        case E3, E65537
    }

    enum CircuitSaltType {
        case S32, S64, S48
    }

    enum CircuitCurveType {
        case SECP256R1, BRAINPOOLP256, BRAINPOOL320R1, SECP192R1
    }

    enum CircuitHashAlgorithmType {
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
        guard let publicKeySize = getPublicKeySupportedSize(CryptoUtils.getPublicKeySize(sodPublicKey)) else {
            return nil
        }

        let signatureType = RegisterIdentityCircuitType.CircuitSignatureType(
            staticId: 0,
            algorithm: sodSignatureAlgorithm.getCircuitSignatureAlgorithm(),
            keySize: publicKeySize,
            exponent: getPublicKeyExponent(sodPublicKey),
            salt: getPublicKeyRSAPSSSaltLength(sod),
            curve: getPublicKeyCurve(sodPublicKey),
            hashAlgorithm: sodSignatureAlgorithm.getCircuitSignatureHashAlgorithm()
        )

        guard let passportHashType = try getEncapsulatedContentDigestAlgorithm(sod) else {
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
            var aaAlgorithm: RegisterIdentityCircuitType.CircuitAlgorithmType
            var aaKeySize: RegisterIdentityCircuitType.CircuitKeySizeType?
            var aaExponent: RegisterIdentityCircuitType.CircuitExponentType?
            var aaCurve: RegisterIdentityCircuitType.CircuitCurveType?
            if let rsaPublicKey = dg15Wrapper.rsaPublicKey {
                pubkeyData = CryptoUtils.getModulusFromRSAPublicKey(rsaPublicKey) ?? Data()
                aaAlgorithm = .RSA

                aaKeySize = getPublicKeySupportedSize(CryptoUtils.getPublicKeySize(rsaPublicKey))
                aaExponent = getPublicKeyExponent(rsaPublicKey)
            } else if let ecdsaPublicKey = dg15Wrapper.ecdsaPublicKey {
                pubkeyData = CryptoUtils.getXYFromECDSAPublicKey(ecdsaPublicKey) ?? Data()
                aaAlgorithm = .ECDSA

                aaCurve = getPublicKeyCurve(ecdsaPublicKey)
            } else {
                throw "Unable to find public key"
            }

            guard let aaKeyPositionShift = dg15.findSubarrayIndex(subarray: pubkeyData) else {
                throw "Unable to find AA key position"
            }

            circuitType.aaType = RegisterIdentityCircuitType.CircuitAAType(
                aaAlgorithm: RegisterIdentityCircuitType.CircuitAAType.CircuitAAAlgorithm(
                    staticId: 0,
                    algorithm: aaAlgorithm,
                    keySize: aaKeySize,
                    exponent: aaExponent,
                    salt: nil,
                    curve: aaCurve,
                    hashAlgorithm: .HA160
                ),
                dg15DigestPositionShift: dg15DigestPositionShift * 8,
                dg15ChunkNumber: dg15ChunkNumber,
                aaKeyPositionShift: aaKeyPositionShift * 8
            )
        }

        return circuitType
    }

    private func getPublicKeySupportedSize(_ size: Int) -> RegisterIdentityCircuitType.CircuitKeySizeType? {
        switch size {
        case 1024:
            return .B1024
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

    private func getPublicKeyExponent(_ publicKey: OpaquePointer?) -> RegisterIdentityCircuitType.CircuitExponentType? {
        guard let exponent = CryptoUtils.getExponentFromRSAPublicKey(publicKey) else { return nil }

        let exponentBN = BN(exponent)

        if exponentBN.cmp(BN(3)) == 0 {
            return .E3
        } else if exponentBN.cmp(BN(65537)) == 0 {
            return .E65537
        } else {
            return nil
        }
    }

    private func getPublicKeyRSAPSSSaltLength(_ sod: SOD) -> RegisterIdentityCircuitType.CircuitSaltType? {
        guard
            let signedData = sod.asn1.getChild(1)?.getChild(0),
            let signerInfo = signedData.getChild(4),
            let signatureAlgoParams = signerInfo.getChild(0)?.getChild(4)?.getChild(1),
            let saltLengthASN1 = signatureAlgoParams.getChild(2)?.getChild(0)
        else {
            return nil
        }

        let saltLengthHex = saltLengthASN1.value
        if saltLengthHex.isEmpty {
            return nil
        }

        guard let saltLengthData = Data(hex: saltLengthHex) else {
            return nil
        }

        var saltLength = UInt64(0)
        _ = withUnsafeMutableBytes(of: &saltLength) {
            saltLengthData.copyBytes(to: $0)
        }

        switch saltLength {
        case 32:
            return .S32
        case 48:
            return .S48
        case 64:
            return .S64
        default:
            return nil
        }
    }

    private func getEncapsulatedContentDigestAlgorithm(_ sod: SOD) throws -> RegisterIdentityCircuitType.CircuitPasssportHashType? {
        guard
            let signedData = sod.asn1.getChild(1)?.getChild(0),
            let privateKeyInfoAsn1 = signedData.getChild(2)?.getChild(1)?.getChild(0)
        else {
            throw OpenSSLError.UnableToExtractSignedDataFromPKCS7("Data in invalid format")
        }

        let privateKeyInfo = try SimpleASN1DumpParser().parse(data: Data(hex: privateKeyInfoAsn1.value))

        guard let privateKeyDigestAlgorithm = privateKeyInfo.getChild(1)?.getChild(0) else {
            throw OpenSSLError.UnableToExtractSignedDataFromPKCS7("Data in invalid format")
        }

        return RegisterIdentityCircuitType.CircuitPasssportHashType(rawValue: privateKeyDigestAlgorithm.value)
    }

    private func getPublicKeyCurve(_ publicKey: OpaquePointer?) -> RegisterIdentityCircuitType.CircuitCurveType? {
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
