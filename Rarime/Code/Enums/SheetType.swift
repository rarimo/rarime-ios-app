//
//  SheetTypes.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import Foundation

enum SheetType: Identifiable {
    case help, notifications

    var id: String {
        switch self {
        case .help: return "help"
        case .notifications: return "notifications"
        }
    }
}
