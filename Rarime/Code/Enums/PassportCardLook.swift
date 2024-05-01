import Foundation
import SwiftUI

enum PassportCardLook: Int, CaseIterable {
    case green, black, white

    var name: LocalizedStringResource {
        switch self {
        case .green: return "Green"
        case .black: return "Black"
        case .white: return "White"
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
