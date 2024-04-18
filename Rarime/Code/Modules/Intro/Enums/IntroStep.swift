//
//  IntroStep.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 29.03.2024.
//

import Foundation

enum IntroStep: Int, CaseIterable {
    case welcome, identity, rewards

    var title: LocalizedStringResource {
        switch self {
        case .welcome: return "Welcome"
        case .identity: return "Become a Citizen"
        case .rewards: return "Get rewarded"
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .welcome: return "This is an app where your digital identity lives and enables you to connect with rest of the web in a fully private mode"
        case .identity: return "Convert existing identity documents into anonymous credentials"
        case .rewards: return "Create a profile, add various credentials, and invite others to earn rewards in the process"
        }
    }

    var image: String {
        switch self {
        case .welcome: return Images.introApp
        case .identity: return Images.introIdentity
        case .rewards: return Images.introGifts
        }
    }
}
