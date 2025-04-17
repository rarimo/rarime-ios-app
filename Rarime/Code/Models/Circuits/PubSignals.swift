import Foundation

private let SIGNALS_SIZE_IN_BYTES: Int = 32

struct QueryIdentityPubSignals {
    var raw: [String]
    
    init(_ raw: [String]) {
        self.raw = raw
    }
    
    enum SignalKey: Int {
        case nullifier = 0
        case birthDate = 1
        case expirationDate = 2
        case name = 3
        case nameResidual = 4
        case nationality = 5
        case citizenship = 6
        case sex = 7
        case documentNumber = 8
        case eventID = 9
        case eventData = 10
        case idStateRoot = 11
        case selector = 12
        case currentDate = 13
        case timestampLowerbound = 14
        case timestampUpperbound = 15
        case identityCounterLowerbound = 16
        case identityCounterUpperbound = 17
        case birthDateLowerbound = 18
        case birthDateUpperbound = 19
        case expirationDateLowerbound = 20
        case expirationDateUpperbound = 21
        case citizenshipMask = 22
    }
    
    func getSignal(_ key: SignalKey) throws -> BN {
        let value = raw[key.rawValue]
        
        return try BN(dec: value)
    }
    
    func getSignalRaw(_ key: SignalKey) -> String {
        return raw[key.rawValue]
    }
}

struct RegisterIdentityPubSignals {
    var raw: [BN]
    
    init(_ zkProof: ZkProof) {
        switch zkProof {
        case .groth(let proof):
            self.init(proof.pubSignals)
        case .plonk(let data):
            self.init(data)
        }
    }
    
    init(_ raw: [String]) {
        self.raw = raw.map { (try? BN(dec: $0)) ?? BN(0) }
    }
    
    init(_ data: Data) {
        self.raw = []
        
        let signalsCount = SignalKey.allCases.count
        for i in 0..<signalsCount {
            let signalData = data.subdata(in: i * SIGNALS_SIZE_IN_BYTES..<(i + 1) * SIGNALS_SIZE_IN_BYTES)
            
            let signal = BN(signalData)
            raw.append(signal)
        }
    }
    
    enum SignalKey: Int, CaseIterable {
        case passportKey = 0
        case passportHash = 1
        case dgCommit = 2
        case identityKey = 3
        case certificatesRoot = 4
    }
    
    func getSignal(_ key: SignalKey) throws -> BN {
        return raw[key.rawValue]
    }
    
    func getSignalRaw(_ key: SignalKey) -> String {
        return raw[key.rawValue].dec()
    }
}

struct RegisterIdentityLightPubSignals {
    var raw: [String]
    
    init(_ raw: [String]) {
        self.raw = raw
    }
    
    enum SignalKey: Int, CaseIterable {
        case passportHash = 0
        case dgCommit = 1
        case identityKey = 2
    }
    
    func getSignal(_ key: SignalKey) throws -> BN {
        let value = raw[key.rawValue]
        
        return try BN(dec: value)
    }
    
    func getSignalRaw(_ key: SignalKey) -> String {
        return raw[key.rawValue]
    }
}
