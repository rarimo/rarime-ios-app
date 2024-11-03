import Foundation
import Identity
import NFCPassportReader
import OpenSSL
import Security
import Web3

class CircuitBuilderManager {
    static let shared = CircuitBuilderManager()
    
    let registerIdentityCircuit = RegisterIdentityCircuit()
    let registerContestantCircuit = RegisterContestantCircuit()
}

extension CircuitBuilderManager {
    class RegisterContestantCircuit {
        func buildInputs(
        ) async throws -> RegisterContestantInputs {
            let user = UserManager.shared.user!
            let passport = PassportManager.shared.passport!
            let registerZkProof = UserManager.shared.registerZkProof!
            
            let stateKeeperContract = try StateKeeperContract()
            
            let registrationSmtContractAddress = try EthereumAddress(hex: ConfigManager.shared.api.registrationSmtContractAddress, eip55: false)
            
            let registrationSmtContract = try PoseidonSMT(contractAddress: registrationSmtContractAddress)
            
            let passportInfoKey: String
            if passport.dg15.isEmpty {
                passportInfoKey = registerZkProof.pubSignals[1]
            } else {
                passportInfoKey = registerZkProof.pubSignals[0]
            }
            
            var error: NSError? = nil
            let proofIndex = IdentityCalculateProofIndex(
                passportInfoKey,
                registerZkProof.pubSignals[3],
                &error
            )
            if let error { throw error }
            guard let proofIndex else { throw "proof index is not initialized" }
            
            let smtProof = try await registrationSmtContract.getProof(proofIndex)
            
            let (passportInfo, identityInfo) = try await stateKeeperContract.getPassportInfo(passportInfoKey)
            
            let sod = try passport.getSod()
            
            let encapsulatedContent = try sod.getEncapsulatedContent()
            let dg2Hash = try passport.getDG2Hash()
            
            let publicKey = try sod.getPublicKey()
            
            guard let pubkeyData = CryptoUtils.getDataFromPublicKey(publicKey) else {
                throw "invalid pubkey data"
            }
            
            let smartChunkingToBlockSize = UInt64(512)
            
            let ecChunkNumber = getChunkNumber(encapsulatedContent, 512)
            
            return .init(
                encapsulatedContent: CircuitUtils.smartChunking2(encapsulatedContent, UInt64(ecChunkNumber), smartChunkingToBlockSize),
                dg1: CircuitUtils.smartChunking2(passport.dg1, 2, smartChunkingToBlockSize),
                dg2Hash: CircuitUtils.byteArrayToBits(dg2Hash),
                idStateSiblings: smtProof.siblings.map { $0.fullHex },
                timestamp: identityInfo.issueTimestamp.description,
                identityCounter: passportInfo.identityReissueCounter.description,
                skIdentity: user.secretKey.fullHex,
                pkPassportHash: passportInfoKey,
                idStateRoot: smtProof.root.fullHex
            )
        }
        
        private func getChunkNumber(_ data: Data, _ chunkSize: UInt) -> UInt {
            let length = UInt(data.count) * 8 + 1 + 64

            return length / chunkSize + (length % chunkSize == 0 ? 0 : 1)
        }
    }
    
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
            
            return RegisterIdentityInputs(
                skIdentity: privateKey.fullHex,
                encapsulatedContent: CircuitUtils.smartChunking2(encapsulatedContent, UInt64(circuitType.ecChunkNumber), smartChunkingToBlockSize),
                signedAttributes: CircuitUtils.smartChunking2(signedAttributes, 2, smartChunkingToBlockSize),
                pubkey: CircuitUtils.smartChunking(BN(pubkeyData), chunksNumber: smartChunkingNumber),
                signature: CircuitUtils.smartChunking(BN(signature), chunksNumber: smartChunkingNumber),
                dg1: CircuitUtils.smartChunking2(passport.dg1, 2, smartChunkingToBlockSize),
                dg15: dg15,
                slaveMerkleRoot: certProof.root.fullHex,
                slaveMerkleInclusionBranches: certProof.siblings.map { $0.fullHex }
            )
        }
    }
}
