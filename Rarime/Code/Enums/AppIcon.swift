import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable {
    case blackAndWhite
    case blackAndGreen
    case greenAndBlack
}

extension AppIcon {
    var image: String {
        switch self {
        case .blackAndWhite: return "BlackAndWhiteIcon"
        case .blackAndGreen: return "BlackAndGreenIcon"
        case .greenAndBlack: return "GreenAndBlackIcon"
        }
    }
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
