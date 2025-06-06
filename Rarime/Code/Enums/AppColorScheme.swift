import Foundation
import SwiftUI

enum AppColorScheme: Int, CaseIterable {
    case light, dark, system
}

extension AppColorScheme {
    var title: String {
        switch self {
        case .light: String(localized: "Light Mode")
        case .dark: String(localized: "Dark Mode")
        case .system: String(localized: "System")
        }
    }
}

extension AppColorScheme {
    var image: ImageResource {
        switch self {
        case .light: .lightTheme
        case .dark: .darkTheme
        case .system: .systemTheme
        }
    }
}

extension AppColorScheme {
    var rawScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}
