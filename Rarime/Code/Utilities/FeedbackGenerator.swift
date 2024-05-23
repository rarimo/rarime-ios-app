import Foundation
import UIKit

class FeedbackGenerator {
    static let shared = FeedbackGenerator()

    private let notificationGenerator = UINotificationFeedbackGenerator()

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.prepare()
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
