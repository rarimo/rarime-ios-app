import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable {
    case black = "BlackIcon"
    case green = "GreenIcon"
    case gradient = "GradientIcon"
    case white = "WhiteIcon"
    case cat = "CatIcon"
}

extension AppIcon {
    var isDefault: Bool {
        self == .black
    }
}

extension AppIcon {
    var title: String {
        switch self {
        case .black: return String(localized: "Black")
        case .green: return String(localized: "Green")
        case .gradient: return String(localized: "Gradient")
        case .white: return String(localized: "White")
        case .cat: return String(localized: "Cat")
        }
    }
}

extension AppIcon {
    var image: ImageResource {
        switch self {
        case .black: return .blackIcon
        case .green: return .greenIcon
        case .gradient: return .gradientIcon
        case .white: return .whiteIcon
        case .cat: return .catIcon
        }
    }
}
