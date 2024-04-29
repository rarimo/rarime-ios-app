import Foundation

enum AppLanguage: String, CaseIterable {
    case engish = "EN"
    case ukrainian = "UK"
    case georgian = "GE"
}

extension AppLanguage {
    var title: String {
        switch self {
        case .engish: return String(localized: "English")
        case .ukrainian: return String(localized: "Ukrainian")
        case .georgian: return String(localized: "Georgian")
        }
    }
}
