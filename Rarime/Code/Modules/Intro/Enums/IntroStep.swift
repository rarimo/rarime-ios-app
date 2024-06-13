import Foundation

enum IntroStep: Int, CaseIterable {
    case welcome, incognito, proofs, rewards

    var title: LocalizedStringResource {
        switch self {
        case .welcome: return "Welcome"
        case .incognito: return "Go Incognito"
        case .proofs: return "Proofs"
        case .rewards: return "Get Rewarded"
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .welcome: return "This app is where you privately store your digital identities, enabling you to go incognito across the web."
        case .incognito: return "RariMe ensures your history, reputation and actions are not lost, and remain under your control."
        case .proofs: return "Prove your eligibility, belonging, identity, and contributions — all without revealing your personal details."
        case .rewards: return "Start building your incognito profile and earn rewards as an early community member."
        }
    }

    var animation: ThemedAnimation {
        switch self {
        case .welcome: return Animations.introWelcome
        case .incognito: return Animations.introIncognito
        case .proofs: return Animations.introProofs
        case .rewards: return Animations.introRewards
        }
    }

    var animationWidth: CGFloat {
        switch self {
        case .welcome: return 390
        case .incognito: return 342
        case .proofs: return 320
        case .rewards: return 200
        }
    }
}
