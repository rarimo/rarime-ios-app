import SwiftUI

enum ProcessingStatus: Equatable {
    case downloading(String), processing, success, failure

    var icon: String? {
        switch self {
        case .downloading(_): nil
        case .processing: nil
        case .success: Icons.check
        case .failure: Icons.close
        }
    }

    var text: String {
        switch self {
        case .downloading(let progress):
            return progress
        case .processing:
            return String(localized: "Processing")
        case .success:
            return String(localized: "Done")
        case .failure:
            return String(localized: "Failed")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .downloading, .processing: .warningLighter
        case .success: .successLighter
        case .failure: .errorLighter
        }
    }

    var foregroundColor: Color {
        switch self {
        case  .downloading, .processing: .warningDark
        case .success: .successDark
        case .failure: .errorMain
        }
    }
}
