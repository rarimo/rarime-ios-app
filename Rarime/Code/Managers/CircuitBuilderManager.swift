import Identity
import NFCPassportReader
import OpenSSL
import Security
import SwiftUI
import Web3

class CircuitBuilderManager {
    static let shared = CircuitBuilderManager()
    
    let registerIdentityCircuit = RegisterIdentityCircuit()
    let registerIdentityLightCircuit = RegisterIdentityLightCircuit()
    let noirRegisterIdentityCircuit = NoirRegisterIdentityCircuit()
    let bionetCircuit = BionetCircuit()
}

extension CircuitBuilderManager {
    class RegisterIdentityCircuit {
        func buildInputs(
            _ privateKey: Data,
            _ passport: Passport,
            _ circuitType: RegisterIdentityCircuitType
        ) async throws -> RegisterIdentityInputs {
            let slaveCertPem = try passport.getSlaveSodCertificatePem()
            
            let certProof = try await passport.getCertificateSmtProof(slaveCertPem)
            
            let sod = try passport.getSod()
            let encapsulatedContent = try sod.getEncapsulatedContent()
            let signedAttributes = try sod.getSignedAttributes()
            let signature = try sod.getSignature()
            let publicKey = try sod.getPublicKey()
            
            guard let pubkeyData = CryptoUtils.getDataFromPublicKey(publicKey) else {
                throw "invalid pubkey data"
            }
            
            let smartChunkingNumber = CircuitUtils.calculateSmartChunkingNumber(pubkeyData.count * 8)
            
            let smartChunkingToBlockSize = UInt64(circuitType.passportHashType.getChunkSize())
            
            var dg15: [Int64] = []
            if !passport.dg15.isEmpty {
                dg15 = CircuitUtils.smartChunking2(
                    passport.dg15,
                    UInt64(circuitType.aaType!.dg15ChunkNumber),
                    smartChunkingToBlockSize
                )
            }
            
            var pubKeyInput: [BN]
            var signatureInput: [BN]
            switch circuitType.signatureType.algorithm {
            case .RSA, .RSAPSS:
                pubKeyInput = CircuitUtils.smartChunking(BN(pubkeyData), chunksNumber: smartChunkingNumber)
                
                signatureInput = CircuitUtils.smartChunking(BN(signature), chunksNumber: smartChunkingNumber)
            case .ECDSA:
                pubKeyInput = CircuitUtils.byteArrayToBits(pubkeyData).map { BN(UInt($0)) }
                
                let signatureData = try CryptoUtils.decodeECDSASignatureFromASN1(signature)
                signatureInput = CircuitUtils.byteArrayToBits(signatureData).map { BN(UInt($0)) }
            }
            
            return RegisterIdentityInputs(
                skIdentity: privateKey.fullHex,
                encapsulatedContent: CircuitUtils.smartChunking2(encapsulatedContent, UInt64(circuitType.ecChunkNumber), smartChunkingToBlockSize),
                signedAttributes: CircuitUtils.smartChunking2(signedAttributes, 2, smartChunkingToBlockSize),
                pubkey: pubKeyInput,
                signature: signatureInput,
                dg1: CircuitUtils.smartChunking2(passport.dg1, 2, smartChunkingToBlockSize),
                dg15: dg15,
                slaveMerkleRoot: certProof.root.fullHex,
                slaveMerkleInclusionBranches: certProof.siblings.map { $0.fullHex }
            )
        }
    }
}

extension CircuitBuilderManager {
    class RegisterIdentityLightCircuit {
        func buildInputs(_ privateKey: Data, _ passport: Passport) throws -> RegisterIdentityLightInputs {
            return RegisterIdentityLightInputs(
                skIdentity: privateKey.fullHex,
                dg1: CircuitUtils.smartChunking2(passport.dg1, 2, 512)
            )
        }
    }
}

extension CircuitBuilderManager {
    class NoirRegisterIdentityCircuit {
        func buildInputs(
            _ privateKey: Data,
            _ passport: Passport,
            _ registerIdentityCircuitType: RegisterIdentityCircuitType
        ) async throws -> NoirRegisterIdentityInputs {
            let slaveCertPem = try passport.getSlaveSodCertificatePem()
            
            let certProof = try await passport.getCertificateSmtProof(slaveCertPem)
            
            let sod = try passport.getSod()
            let encapsulatedContent = try sod.getEncapsulatedContent()
            let signedAttributes = try sod.getSignedAttributes()
            var signature = try sod.getSignature()
            let publicKey = try sod.getPublicKey()
            
            guard let pubkeyData = CryptoUtils.getDataFromPublicKey(publicKey) else {
                throw "invalid pubkey data"
            }
            
            let reductionPk: [String]
            let pk: [String]
            let sig: [String]
            switch registerIdentityCircuitType.signatureType.algorithm {
            case .RSA, .RSAPSS:
                pk = CircuitUtils.splitBy120Bits(pubkeyData).map { $0.dec() }
                
                reductionPk = CircuitUtils.RSABarrettReductionParam(BN(pubkeyData), UInt(pubkeyData.count * 8)).map { $0.dec() }
                
                sig = CircuitUtils.splitBy120Bits(signature).map { $0.dec() }
            case .ECDSA:
                
                let pubKeyX = pubkeyData.subdata(in: 0..<pubkeyData.count / 2)
                let pubKeyY = pubkeyData.subdata(in: pubkeyData.count / 2..<pubkeyData.count)
                
                pk = (CircuitUtils.splitBy120Bits(pubKeyX) + CircuitUtils.splitBy120Bits(pubKeyY)).map { $0.dec() }
                
                reductionPk = (CircuitUtils.splitEmptyData(pubKeyX) + CircuitUtils.splitEmptyData(pubKeyY)).map { $0.dec() }
                
                signature = try CryptoUtils.decodeECDSASignatureFromASN1(signature)
                
                let sigR = signature.subdata(in: 0..<signature.count / 2)
                let sigS = signature.subdata(in: signature.count / 2..<signature.count)
                
                sig = (CircuitUtils.splitBy120Bits(sigR) + CircuitUtils.splitBy120Bits(sigS)).map { $0.fullHex() }
            }
            
            return .init(
                dg1: passport.dg1.map { $0.description },
                dg15: passport.dg15.map { $0.description },
                ec: encapsulatedContent.map { $0.description },
                icaoRoot: BN(certProof.root).dec(),
                inclusionBranches: certProof.siblings.map { BN($0).dec() },
                pk: pk,
                reductionPk: reductionPk,
                sa: signedAttributes.map { $0.description },
                sig: sig,
                skIdentity: BN(privateKey).dec()
            )
        }
    }
}

extension CircuitBuilderManager {
    private static let threshold: Int = 107374182
    
    class BionetCircuit {
        func inputs(
            _ imageData: Data,
            _ features: [Float],
            _ nonce: BN,
            _ address: BN
        ) -> BionetInputs {
            var imageMatrix: [[String]] = []
            for x in 0..<TensorFlow.bionetImageBoundary {
                var imageRow: [String] = []
                for y in 0..<TensorFlow.bionetImageBoundary {
                    let pixelValue = imageData[x * TensorFlow.bionetImageBoundary + y]
                    imageRow.append(Int(pixelValue).description)
                }
                
                imageMatrix.append(imageRow)
            }
            
            return .init(
                image: [imageMatrix],
                features: features.map { Int($0 * 255).description },
                nonce: nonce.dec(),
                address: address.dec(),
                threshold: CircuitBuilderManager.threshold.description
            )
        }
    }
}
