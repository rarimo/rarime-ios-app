import Foundation

class ZKUtils {
    static let ERROR_SIZE = UInt(256)
    static let WITNESS_SIZE = UInt(100 * 1024 * 1024)
    static let PROOF_SIZE = UInt(4 * 1024 * 1024)
    static let PUB_SIGNALS_SIZE = UInt(4 * 1024 * 1024)
    
    public static func calcWtnsRegisterIdentity_1_256_3_5_576_248_NA(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_1_256_3_5_576_248_NA(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_1_256_3_6_576_248_1_2432_5_296(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_1_256_3_6_576_248_1_2432_5_296(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_2_256_3_6_336_264_21_2448_6_2008(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_2_256_3_6_336_264_21_2448_6_2008(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_21_256_3_7_336_264_21_3072_6_2008(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_21_256_3_7_336_264_21_3072_6_2008(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_1_256_3_6_576_264_1_2448_3_256(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_1_256_3_6_576_264_1_2448_3_256(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_2_256_3_6_336_248_1_2432_3_256(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_2_256_3_6_336_248_1_2432_3_256(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_2_256_3_6_576_248_1_2432_3_256(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_2_256_3_6_576_248_1_2432_3_256(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_11_256_3_3_576_248_1_1184_5_264(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_11_256_3_3_576_248_1_1184_5_264(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_12_256_3_3_336_232_NA(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_12_256_3_3_336_232_NA(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_1_256_3_4_336_232_1_1480_5_296(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_1_256_3_4_336_232_1_1480_5_296(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsRegisterIdentity_1_256_3_4_600_248_1_1496_3_256(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_registerIdentity_1_256_3_4_600_248_1_1496_3_256(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsQueryIdentity(_ privateInputsJson: Data) throws -> Data {
        return try _calcWtnsQueryIdentity(Circuits.queryIdentityDat, privateInputsJson)
    }
    
    private static func _calcWtnsQueryIdentity(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_queryIdentity(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
    }
    
    public static func calcWtnsAuth(_ privateInputsJson: Data) throws -> Data {
        return try _calcWtnsAuth(Circuits.authDat, privateInputsJson)
    }
    
    private static func _calcWtnsAuth(
        _ descriptionFileData: Data,
        _ privateInputsJson: Data
    ) throws -> Data {
#if targetEnvironment(simulator)
        return Data()
#else
        let wtnsSize = UnsafeMutablePointer<UInt>.allocate(capacity: Int(1))
        wtnsSize.initialize(to: WITNESS_SIZE)
        let wtnsBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(WITNESS_SIZE))
        let errorBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(ERROR_SIZE))
        
        let result = witnesscalc_auth(
            (descriptionFileData as NSData).bytes, UInt(descriptionFileData.count),
            (privateInputsJson as NSData).bytes, UInt(privateInputsJson.count),
            wtnsBuffer, wtnsSize,
            errorBuffer, ERROR_SIZE
        )
        
        try handleWitnessError(result, errorBuffer, wtnsSize)
        
        return Data(bytes: wtnsBuffer, count: Int(wtnsSize.pointee))
#endif
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
