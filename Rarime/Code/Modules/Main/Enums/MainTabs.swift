//
//  MainTabs.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import Foundation

enum MainTabs: Int, CaseIterable {
    case home, wallet, rewards, credentials, settings

    var iconName: String {
        switch self {
        case .home: return Icons.houseSimple
        case .wallet: return Icons.wallet
        case .rewards: return Icons.gift
        case .credentials: return Icons.identificationCard
        case .settings: return Icons.dotsThreeOutline
        }
    }

    var activeIconName: String {
        switch self {
        case .home: return Icons.houseSimpleFill
        case .wallet: return Icons.walletFilled
        case .rewards: return Icons.giftFill
        case .credentials: return Icons.identificationCardFill
        case .settings: return Icons.dotsThreeOutline
        }
    }
}
