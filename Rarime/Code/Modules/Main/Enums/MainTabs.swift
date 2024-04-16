//
//  MainTabs.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import Foundation

enum MainTabs: Int, CaseIterable {
    case home, wallet, rewards, profile

    var iconName: String {
        switch self {
        case .home: return Icons.houseSimple
        case .wallet: return Icons.wallet
        case .rewards: return Icons.airdrop
        case .profile: return Icons.user
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.houseSimpleFill
        case .wallet: return Icons.walletFilled
        case .rewards: return Icons.airdrop
        case .profile: return Icons.user
        }
    }
}
