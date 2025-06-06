import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable {
    case black
    case green
    case gradient
    case white
    case cat
}

extension AppIcon {
    var image: String {
        switch self {
        case .black: return "BlackIcon"
        case .green: return "GreenIcon"
        case .gradient: return "GradientIcon"
        case .white: return "WhiteIcon"
        case .cat: return "CatIcon"
        }
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
