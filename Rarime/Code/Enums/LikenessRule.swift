import SwiftUI

enum LikenessRule: Int {
    case unset
    case useAndPay
    case notUse
    case askFirst
}

extension LikenessRule {
    var title: String {
        switch self {
        case .unset: return String(localized: "Set a rule")
        case .useAndPay: return String(localized: "Use my likeness and pay me")
        case .notUse: return String(localized: "Don’t use my face at all")
        case .askFirst: return String(localized: "Ask me first")
        }
    }
}

extension LikenessRule {
    var icon: ImageResource {
        switch self {
        case .unset: return .questionLine
        case .useAndPay: return .moneyDollarCircleLine
        case .notUse: return .subtractFill
        case .askFirst: return .questionLine
        }
    }
}
