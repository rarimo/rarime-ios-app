import Foundation
import SwiftUI

class LikenessManager: ObservableObject {
    static let shared = LikenessManager()

    @Published var rule: LikenessRule {
        didSet {
            AppUserDefaults.shared.likenessRule = rule.rawValue
        }
    }

    @Published var isRegistered: Bool {
        didSet {
            AppUserDefaults.shared.isLikenessRegistered = isRegistered
        }
    }

    @Published var faceImage: UIImage?

    init() {
        rule = .init(rawValue: AppUserDefaults.shared.likenessRule) ?? .unset
        isRegistered = AppUserDefaults.shared.isLikenessRegistered

        let imageData = try? AppKeychain.getValue(.likenessFace)
        faceImage = imageData == nil ? nil : UIImage(data: imageData!)
    }

    func setRule(_ rule: LikenessRule) {
        self.rule = rule
    }

    func setIsRegistered(_ isRegistered: Bool) {
        self.isRegistered = isRegistered
    }

    func setFaceImage(_ image: UIImage?) {
        faceImage = image
        if let imageData = image?.pngData() {
            try? AppKeychain.setValue(.likenessFace, imageData)
        } else {
            try? AppKeychain.removeValue(.likenessFace)
        }
    }

    func reset() {
        setRule(.unset)
        setIsRegistered(false)
        setFaceImage(nil)
    }
}
