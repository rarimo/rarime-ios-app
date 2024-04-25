import Foundation

enum IntroStep: Int, CaseIterable {
    case welcome, incognito, proofs, rewards

    var title: LocalizedStringResource {
        switch self {
        case .welcome: return "Welcome"
        case .incognito: return "Incognito"
        case .proofs: return "Proofs"
        case .rewards: return "Get rewarded"
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .welcome: return "This app is where your digital identities live, enabling you to go incognito across the web."
        case .incognito: return "Ensuring your history, reputation and actions are not lost, but still remain confidential controlled by you."
        case .proofs: return "Prove your eligibility, belonging, identity, and contributions — all without revealing who you are."
        case .rewards: return "Start building your incognito profile and earn rewards as an early community member."
        }
    }

    var image: String {
        switch self {
        case .welcome: return Images.introApp
        case .incognito: return Images.introPrivacy
        case .proofs: return Images.introShield
        case .rewards: return Images.introGifts
        }
    }
}
