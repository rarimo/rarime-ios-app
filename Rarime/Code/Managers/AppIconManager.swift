import Foundation
import UIKit

class AppIconManager: ObservableObject {
    static let shared = AppIconManager()
    
    @Published private(set) var appIcon: AppIcon
    
    init() {
        self.appIcon = AppIcon(rawValue: UIApplication.shared.alternateIconName ?? "") ?? .blackAndWhite
    }
    
    var isAppIconsSupported: Bool {
        UIApplication.shared.supportsAlternateIcons
    }
    
    func setAppIcon(_ icon: AppIcon) {
        let oldIcon = self.appIcon
        self.appIcon = icon

        UIApplication.shared.setAlternateIconName(icon == .blackAndWhite ? nil : icon.rawValue) { error in
            if let error = error {
                LoggerUtil.common.error("Error setting the app icon: \(error.localizedDescription, privacy: .public)")
                self.appIcon = oldIcon
            }
        }
    }
}
