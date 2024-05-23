import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published private(set) var colorScheme: AppColorScheme
    @Published private(set) var language: AppLanguage

    init() {
        colorScheme = AppColorScheme(rawValue: AppUserDefaults.shared.colorScheme)!
        language = AppLanguage.fromIdentifier(Locale.current.identifier)
    }

    func setColorScheme(_ colorScheme: AppColorScheme) {
        self.colorScheme = colorScheme
        AppUserDefaults.shared.colorScheme = colorScheme.rawValue
    }

    func setLanguage(_ language: AppLanguage) {
        self.language = language
        AppUserDefaults.shared.language = language.rawValue
    }
}
