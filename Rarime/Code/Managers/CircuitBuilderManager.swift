import Foundation
import Identity
import NFCPassportReader
import OpenSSL
import Security
import Web3

class CircuitBuilderManager {
    static let shared = CircuitBuilderManager()
    
    let registerIdentityCircuit = RegisterIdentityCircuit()
    let registerIdentityLightCircuit = RegisterIdentityLightCircuit()
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
