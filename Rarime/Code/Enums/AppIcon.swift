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
        case .blackAndWhite: return Images.blackAndWhiteIcon
        case .blackAndGreen: return Images.blackAndGreenIcon
        case .greenAndBlack: return Images.greenAndBlackIcon
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
