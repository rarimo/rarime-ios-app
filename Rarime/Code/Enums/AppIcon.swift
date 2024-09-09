import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable {
    case blackAndGreen = "BlackAndGreenIcon"
}

extension AppIcon {
    var title: String {
        switch self {
        case .blackAndGreen: return String(localized: "Black & Green")
        }
    }
}
