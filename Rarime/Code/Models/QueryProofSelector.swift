import BigInt
import Foundation

public enum QueryProofField: Int, CaseIterable {
    case nullifier = 0
    case birthDate = 1
    case expirationDate = 2
    case name = 3
    case nationality = 4
    case citizenship = 5
    case sex = 6
    case documentNumber = 7
    case timestampLowerbound = 8
    case timestampUpperbound = 9
    case identityCounterLowerbound = 10
    case identityCounterUpperbound = 11
    case passportExpirationLowerbound = 12
    case passportExpirationUpperbound = 13
    case birthDateLowerbound = 14
    case birthDateUpperbound = 15
    case verifyCitizenshipWhitelist = 16
    case verifyCitizenshipBlacklist = 17

    public var displayName: String {
        switch self {
        case .nullifier: return "Incognito ID"
        case .birthDate: return "Birth date"
        case .expirationDate: return "Expiration date"
        case .name: return "Name"
        case .nationality: return "Nationality"
        case .citizenship: return "Citizenship"
        case .sex: return "Sex"
        case .documentNumber: return "Document number"
        case .timestampLowerbound: return "Registered after"
        case .timestampUpperbound: return "Registered before"
        case .identityCounterLowerbound: return "Min registrations"
        case .identityCounterUpperbound: return "Max registrations"
        case .passportExpirationLowerbound: return "Expiration after"
        case .passportExpirationUpperbound: return "Expiration before"
        case .birthDateLowerbound: return "Born after"
        case .birthDateUpperbound: return "Born before"
        case .verifyCitizenshipWhitelist: return "Citizenship whitelist"
        case .verifyCitizenshipBlacklist: return "Citizenship blacklist"
        }
    }

    public var mask: BigUInt {
        BigUInt(1) << BigUInt(rawValue)
    }
}

public struct QueryProofSelector {
    public private(set) var mask: BigUInt

    public init(mask: BigUInt = 0) {
        self.mask = mask
    }

    public init(hex: String) {
        self.mask = BigUInt(hex.dropFirst(2), radix: 16) ?? 0
    }

    public init(decimalString: String) {
        self.mask = BigUInt(decimalString) ?? 0
    }

    public var hex: String {
        mask.serialize().toHexString()
    }

    public var enabledFields: [QueryProofField] {
        QueryProofField.allCases.filter { (mask & $0.mask) != 0 }
    }
}
