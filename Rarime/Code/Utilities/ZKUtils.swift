import Foundation

import RarimeIOSUtils

import Swoir
import Swoirenberg

class ZKUtils {
    static let ERROR_SIZE = UInt(256)
    static let WITNESS_SIZE = UInt(100 * 1024 * 1024)
    static let PROOF_SIZE = UInt(4 * 1024 * 1024)
    static let PUB_SIGNALS_SIZE = UInt(4 * 1024 * 1024)
    
    #registerCircuitWitness("auth")
    #registerCircuitWitness("queryIdentity")
    #registerCircuitWitness("registerIdentity_1_256_3_5_576_248_NA")
    #registerCircuitWitness("registerIdentity_1_256_3_6_576_248_1_2432_5_296")
    #registerCircuitWitness("registerIdentity_2_256_3_6_336_264_21_2448_6_2008")
    #registerCircuitWitness("registerIdentity_21_256_3_7_336_264_21_3072_6_2008")
    #registerCircuitWitness("registerIdentity_1_256_3_6_576_264_1_2448_3_256")
    #registerCircuitWitness("registerIdentity_2_256_3_6_336_248_1_2432_3_256")
    #registerCircuitWitness("registerIdentity_2_256_3_6_576_248_1_2432_3_256")
    #registerCircuitWitness("registerIdentity_11_256_3_3_576_248_1_1184_5_264")
    #registerCircuitWitness("registerIdentity_12_256_3_3_336_232_NA")
    #registerCircuitWitness("registerIdentity_1_256_3_4_336_232_1_1480_5_296")
    #registerCircuitWitness("registerIdentity_1_256_3_4_600_248_1_1496_3_256")
    #registerCircuitWitness("registerIdentity_1_160_3_3_576_200_NA")
    #registerCircuitWitness("registerIdentity_21_256_3_3_336_232_NA")
    #registerCircuitWitness("registerIdentity_24_256_3_4_336_232_NA")
    #registerCircuitWitness("registerIdentity_1_256_3_3_576_248_NA")
    #registerCircuitWitness("registerIdentity_20_256_3_3_336_224_NA")
    #registerCircuitWitness("registerIdentity_21_256_3_3_576_232_NA")
    #registerCircuitWitness("registerIdentity_11_256_3_5_576_248_1_1808_4_256")
    #registerCircuitWitness("registerIdentity_10_256_3_3_576_248_1_1184_5_264")
    #registerCircuitWitness("registerIdentityLight160")
    #registerCircuitWitness("registerIdentityLight224")
    #registerCircuitWitness("registerIdentityLight256")
    #registerCircuitWitness("registerIdentityLight384")
    #registerCircuitWitness("registerIdentityLight512")
    #registerCircuitWitness("registerIdentity_2_256_3_6_336_264_1_2448_3_256")
    #registerCircuitWitness("registerIdentity_3_160_3_3_336_200_NA")
    #registerCircuitWitness("registerIdentity_3_160_3_4_576_216_1_1512_3_256")
    #registerCircuitWitness("registerIdentity_11_256_3_3_576_240_1_864_5_264")
    #registerCircuitWitness("registerIdentity_21_256_3_4_576_232_NA")
    #registerCircuitWitness("registerIdentity_11_256_3_5_576_248_1_1808_5_296")
    #registerCircuitWitness("registerIdentity_1_256_3_6_336_248_1_2744_4_256")
    #registerCircuitWitness("registerIdentity_1_256_3_6_336_560_1_2744_4_256")
    #registerCircuitWitness("registerIdentity_4_160_3_3_336_216_1_1296_3_256")
    #registerCircuitWitness("registerIdentity_11_256_3_3_336_248_NA")
    #registerCircuitWitness("registerIdentity_14_256_3_4_336_64_1_1480_5_296")
    #registerCircuitWitness("registerIdentity_15_512_3_3_336_248_NA")
    #registerCircuitWitness("registerIdentity_20_160_3_3_736_200_NA")
    #registerCircuitWitness("registerIdentity_20_256_3_5_336_72_NA")
    #registerCircuitWitness("registerIdentity_21_256_3_5_576_232_NA")
    
    public static func groth16QueryIdentity(_ wtns: Data) throws -> (proof: Data, pubSignals: Data) {
        return try groth16Prover(Circuits.queryIdentityZkey, wtns)
    }
    
    public static func groth16Auth(_ wtns: Data) throws -> (proof: Data, pubSignals: Data) {
        return try groth16Prover(Circuits.authZkey, wtns)
    }
    
    public static func groth16Prover(_ zkey: Data, _ wtns: Data) throws -> (proof: Data, pubSignals: Data) {
#if targetEnvironment(simulator)
        return (Data(), Data())
#else
        var proofSize = PROOF_SIZE
        var pubSignalsSize = PUB_SIGNALS_SIZE
        
        let proofBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(PROOF_SIZE))
        let pubSignalsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(PUB_SIGNALS_SIZE))
        
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = groth16_prover(
            (zkey as NSData).bytes, UInt(zkey.count),
            (wtns as NSData).bytes, UInt(wtns.count),
            proofBuffer, &proofSize,
            pubSignalsBuffer, &pubSignalsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleGroth16ProverError(result, errorBuffer)
        
        var proof = Data(bytes: proofBuffer, count: Int(proofSize))
        var pubSignals = Data(bytes: pubSignalsBuffer, count: Int(pubSignalsSize))
        
        let proofNullIndex = proof.firstIndex(of: 0x00)!
        let pubSignalsNullIndex = pubSignals.firstIndex(of: 0x00)!
        
        proof = proof[0..<proofNullIndex]
        pubSignals = pubSignals[0..<pubSignalsNullIndex]
        
        return (proof: proof, pubSignals: pubSignals)
#endif
    }
    
    public static func ultraPlonk(
        _ trustedSetupPath: String,
        _ circuitData: Data,
        _ inputs: [String: Any]
    ) throws -> Data {
        let circuit = try Swoir(backend: Swoirenberg.self)
            .createCircuit(manifest: circuitData)
        
        try circuit.setupSrs(srs_path: trustedSetupPath)

        let proof = try circuit.prove(inputs, proof_type: "plonk")
        
        return proof.proof
    }
    
    private static func handleGroth16ProverError(
        _ result: Int32,
        _ errorBuffer: UnsafeMutablePointer<UInt8>
    ) throws {
        if result == PROVER_ERROR {
            throw String(bytes: Data(bytes: errorBuffer, count: Int(ERROR_SIZE)), encoding: .utf8)!
                .replacingOccurrences(of: "\0", with: "")
        }
        
        if result == PROVER_ERROR_SHORT_BUFFER {
            throw "Proof or public signals buffer is too short"
        }
    }
    
    private static func handleWitnessError(
        _ result: Int32,
        _ errorBuffer: UnsafeMutablePointer<UInt8>,
        _ wtnsSize: UnsafeMutablePointer<UInt>
    ) throws {
        if result == WITNESSCALC_ERROR {
            throw String(bytes: Data(bytes: errorBuffer, count: Int(ERROR_SIZE)), encoding: .utf8)!
                .replacingOccurrences(of: "\0", with: "")
        }
        
        if result == WITNESSCALC_ERROR_SHORT_BUFFER {
            throw String("Buffer to short, should be at least: \(wtnsSize.pointee)")
        }
    }
}
