import SwiftUI

enum HomeWidget: String, Hashable, CaseIterable {
    case earn
    case freedomTool
    case hiddenKeys
    case recovery
    case likeness
}

extension HomeWidget {
    var title: String {
        switch self {
        case .earn: String(localized: "Earn RMO")
        case .freedomTool: String(localized: "Freedomtool")
        case .hiddenKeys: String(localized: "Hidden keys")
        case .recovery: String(localized: "Recovery Method")
        case .likeness: String(localized: "Digital Likeness")
        }
    }

    var description: String {
        switch self {
        case .earn: String(localized: "Complete various tasks and get rewarded with\nRarimo tokens.")
        case .freedomTool: String(localized: "Revolutionizing polling, surveying\nand election processes")
        case .hiddenKeys: String(localized: "Somewhere out on the open web, one famous face carries a key sealed inside its ZK-vector.")
        case .recovery: String(localized: "Set up a new way to recover\nyour account")
        case .likeness: String(localized: "Your data, your rules")
        }
    }
}

extension HomeWidget {
    var image: ImageResource {
        switch self {
        case .earn: .rarimoTokens
        case .freedomTool: .freedomtoolWidget
        case .hiddenKeys: .hiddenKeysWidget
        case .recovery: .recoveryWidget
        case .likeness: .likenessWidget
        }
    }
}

extension HomeWidget {
    var isManageable: Bool {
        switch self {
        case .freedomTool, .hiddenKeys, .recovery: return true
        default: return false
        }
    }
}
