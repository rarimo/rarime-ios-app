import Foundation
import SwiftUI

enum PassportCardLook: Int, CaseIterable {
    case holographicViolet, etherealBlue, celestialGlow

    var backgroundImage: ImageResource {
        switch self {
        case .holographicViolet: .cardBg1
        case .etherealBlue: .cardBg2
        case .celestialGlow: .cardBg3
        }
    }
}
