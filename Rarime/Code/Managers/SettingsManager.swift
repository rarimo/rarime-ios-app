import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published private(set) var colorScheme: AppColorScheme

    init() {
        colorScheme = AppColorScheme(rawValue: AppUserDefaults.shared.colorScheme) ?? .system
    }

    func setColorScheme(_ colorScheme: AppColorScheme) {
        self.colorScheme = colorScheme
        AppUserDefaults.shared.colorScheme = colorScheme.rawValue
    }
}
