import Foundation

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
    var raw: [String]
    
    init(_ raw: [String]) {
        self.raw = raw
    }
    
    enum SignalKey: Int, CaseIterable {
        case passportKey = 0
        case passportHash = 1
        case dgCommit = 2
        case identityKey = 3
        case certificatesRoot = 4
    }
    
    func getSignal(_ key: SignalKey) throws -> BN {
        let value = raw[key.rawValue]
        
        return try BN(dec: value)
    }
    
    func getSignalRaw(_ key: SignalKey) -> String {
        return raw[key.rawValue]
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
