import Foundation

import RarimeIOSUtils

#if targetEnvironment(simulator)
#else
import Swoir
import Swoirenberg
#endif

class ZKUtils {
    static let ERROR_SIZE = UInt(256)
    static let WITNESS_SIZE = UInt(100 * 1024 * 1024)
    static let PROOF_SIZE = UInt(4 * 1024 * 1024)
    static let PUB_SIGNALS_SIZE = UInt(4 * 1024 * 1024)
    
    #registerCircuitWitness("faceRegistryNoInclusion")
    #registerCircuitWitness("auth")
    #registerCircuitWitness("queryIdentity")
    #registerCircuitWitness("registerIdentity_21_256_3_7_336_264_21_3072_6_2008")
    #registerCircuitWitness("registerIdentityLight160")
    #registerCircuitWitness("registerIdentityLight224")
    #registerCircuitWitness("registerIdentityLight256")
    #registerCircuitWitness("registerIdentityLight384")
    #registerCircuitWitness("registerIdentityLight512")
    #registerCircuitWitness("registerIdentity_1_256_3_6_336_560_1_2744_4_256")
    #registerCircuitWitness("registerIdentity_4_160_3_3_336_216_1_1296_3_256")
    #registerCircuitWitness("registerIdentity_14_256_3_4_336_64_1_1480_5_296")
    #registerCircuitWitness("registerIdentity_20_160_3_3_736_200_NA")
    #registerCircuitWitness("registerIdentity_20_256_3_5_336_72_NA")
    
    public static func groth16FaceRegistryNoInclusion(_ wtns: Data) throws -> (proof: Data, pubSignals: Data) {
        return try groth16Prover(Circuits.faceRegistryNoInclusionZkey, wtns)
    }
    
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
#if targetEnvironment(simulator)
        return Data()
#else
        
        let circuit = try Swoir(backend: Swoirenberg.self)
            .createCircuit(manifest: circuitData)
        
        try circuit.setupSrs(srs_path: trustedSetupPath)

        let proof = try circuit.prove(inputs, proof_type: "plonk")
        
        return proof.proof
#endif
    }
    
    public static func bionetta(_ inputs: Data) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let result = bionet((inputs as NSData).bytes, UInt(inputs.count))
        if result.error != nil {
            throw ZKUtilsError.bionettaError(
                String(data: Data(bytes: result.error!, count: Int(result.error_size)), encoding: .utf8) ?? "Unknown error"
            )
        }
        
        return Data(bytes: result.data, count: Int(result.len))
#endif
    }
    
    public static func getNoirVerificationKey(
        _ trustedSetupPath: String,
        _ circuitData: Data
    ) throws -> String {
#if targetEnvironment(simulator)
        return ""
#else
        let circuit = try Swoir(backend: Swoirenberg.self)
            .createCircuit(manifest: circuitData)
        
        try circuit.setupSrs(srs_path: trustedSetupPath)
        
        return try Swoirenberg.get_verification_key(bytecode: circuit.bytecode)
#endif
    }
    
    private static func handleGroth16ProverError(
        _ result: Int32,
        _ errorBuffer: UnsafeMutablePointer<UInt8>
    ) throws {
        if result == PROVER_ERROR {
            throw ZKUtilsError.groth16ProverError(
                String(bytes: Data(bytes: errorBuffer, count: Int(ERROR_SIZE)), encoding: .utf8) ?? "Unknown error"
            )
        }
        
        if result == PROVER_ERROR_SHORT_BUFFER {
            throw ZKUtilsError.shortBufferError("short groth16 proof buffer")
        }
    }
    
    private static func handleWitnessError(
        _ result: Int32,
        _ errorBuffer: UnsafeMutablePointer<UInt8>,
        _ wtnsSize: UnsafeMutablePointer<UInt>
    ) throws {
        if result == WITNESSCALC_ERROR {
            throw ZKUtilsError.witnessCalculationError(
                String(bytes: Data(bytes: errorBuffer, count: Int(ERROR_SIZE)), encoding: .utf8) ?? "Unknown error"
            )
        }
        
        if result == WITNESSCALC_ERROR_SHORT_BUFFER {
            throw ZKUtilsError.shortBufferError("should be at least: \(wtnsSize.pointee)")
        }
    }
}

enum ZKUtilsError: Error {
    case bionettaError(String)
    case groth16ProverError(String)
    case witnessCalculationError(String)
    case shortBufferError(String)
    
    var localizedDescription: String {
        switch self {
        case .bionettaError(let message):
            return "Bionetta Error: \(message)"
        case .groth16ProverError(let message):
            return "Groth16 Prover Error: \(message)"
        case .witnessCalculationError(let message):
            return "Witness Calculation Error: \(message)"
        case .shortBufferError(let message):
            return "Short Buffer Error: \(message)"
        }
    }
}
