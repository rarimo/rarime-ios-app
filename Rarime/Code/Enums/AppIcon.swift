import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable {
    case blackAndWhite = "BlackAndWhiteIcon"
    case blackAndGreen = "BlackAndGreenIcon"
    case greenAndBlack = "GreenAndBlackIcon"
}

extension AppIcon {
    var title: String {
        switch self {
        case .blackAndWhite: return String(localized: "Black & White")
        case .blackAndGreen: return String(localized: "Black & Green")
        case .greenAndBlack: return String(localized: "Green & Black")
        }
    }
}
