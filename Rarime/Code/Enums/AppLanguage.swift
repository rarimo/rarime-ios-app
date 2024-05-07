import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case ukrainian = "uk"
    case georgian = "ka"
}

extension AppLanguage {
    var title: String {
        switch self {
        case .english: return String(localized: "English")
        case .ukrainian: return String(localized: "Ukrainian")
        case .georgian: return String(localized: "Georgian")
        }
    }
}

extension AppLanguage {
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .ukrainian: return "🇺🇦"
        case .georgian: return "🇬🇪"
        }
    }
}

extension AppLanguage {
    static func fromIdentifier(_ identifier: String) -> AppLanguage {
        return AppLanguage.allCases.first { identifier.starts(with: $0.rawValue) } ?? .english
    }
}
