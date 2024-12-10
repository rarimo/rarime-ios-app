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
        case nationality = 4
        case citizenship = 5
        case sex = 6
        case documentNumberHash = 7
        case personalNumberHash = 8
        case documentType = 9
        case eventID = 10
        case eventData = 11
        case idStateRoot = 12
        case selector = 13
        case currentDate = 14
        case timestampLowerbound = 15
        case timestampUpperbound = 16
        case identityCounterLowerbound = 17
        case identityCounterUpperbound = 18
        case birthDateLowerbound = 19
        case birthDateUpperbound = 20
        case expirationDateLowerbound = 21
        case expirationDateUpperbound = 22
        case citizenshipMask = 23
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
