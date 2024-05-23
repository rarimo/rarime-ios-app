import SwiftUI

// Hide navigation bar:
// https://stackoverflow.com/a/68650943
extension UINavigationController {
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.isHidden = true
    }
}
