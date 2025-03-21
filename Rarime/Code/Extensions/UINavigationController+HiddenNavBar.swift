import SwiftUI

// Hide navigation bar:
// https://stackoverflow.com/a/77743426
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return gestureRecognizer.isEqual(self.interactivePopGestureRecognizer)
    }
}
