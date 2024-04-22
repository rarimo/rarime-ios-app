import Foundation

enum AppLanguage: String, CaseIterable {
    case engish = "EN"
    case ukrainian = "UK"
}

extension AppLanguage {
    var title: String {
        switch self {
        case .engish: return "English"
        case .ukrainian: return "Українська"
        }
    }
}
