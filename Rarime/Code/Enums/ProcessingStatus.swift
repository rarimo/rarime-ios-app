//
//  ProcessingStatus.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 02.04.2024.
//

import SwiftUI

enum ProcessingStatus {
    case processing, success, failure

    var icon: String? {
        switch self {
        case .processing:
            return nil
        case .success:
            return Icons.check
        case .failure:
            return Icons.close
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .processing:
            return "Processing"
        case .success:
            return "Done"
        case .failure:
            return "Failed"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .processing:
            return .warningLighter
        case .success:
            return .successLighter
        case .failure:
            return .errorLighter
        }
    }

    var foregroundColor: Color {
        switch self {
        case .processing:
            return .warningDark
        case .success:
            return .successDark
        case .failure:
            return .errorMain
        }
    }
}
