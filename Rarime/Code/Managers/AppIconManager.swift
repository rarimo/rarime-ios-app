import Foundation
import UIKit

class AppIconManager: ObservableObject {
    static let shared = AppIconManager()
    
    @Published private(set) var appIcon: AppIcon
    
    init() {
        appIcon = AppIcon(rawValue: UIApplication.shared.alternateIconName ?? "") ?? .blackAndWhite
    }
    
    var isAppIconsSupported: Bool {
        UIApplication.shared.supportsAlternateIcons
    }
    
    func setAppIcon(_ icon: AppIcon) {
        UIApplication.shared.setAlternateIconName(icon == .blackAndWhite ? nil : icon.rawValue) { error in
            if let error = error {
                LoggerUtil.general.error("Error setting the app icon: \(error.localizedDescription)")
            } else {
                self.appIcon = icon
            }
        }
    }
}
