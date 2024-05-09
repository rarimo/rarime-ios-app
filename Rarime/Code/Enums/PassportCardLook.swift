import Foundation
import SwiftUI

enum PassportCardLook: Int, CaseIterable {
    case green, black, white

    var name: String {
        switch self {
        case .green: return String(localized: "Green")
        case .black: return String(localized: "Black")
        case .white: return String(localized: "White")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .green: return .primaryMain
        case .black: return .baseBlack
        case .white: return .baseWhite
        }
    }

    var foregroundColor: Color {
        switch self {
        case .green: return .baseBlack
        case .black: return .baseWhite
        case .white: return .baseBlack
        }
    }
}
