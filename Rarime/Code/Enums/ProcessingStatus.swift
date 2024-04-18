import SwiftUI

enum ProcessingStatus {
    case processing, success, failure

    var icon: String? {
        switch self {
        case .processing: nil
        case .success: Icons.check
        case .failure: Icons.close
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .processing: "Processing"
        case .success: "Done"
        case .failure: "Failed"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .processing: .warningLighter
        case .success: .successLighter
        case .failure: .errorLighter
        }
    }

    var foregroundColor: Color {
        switch self {
        case .processing: .warningDark
        case .success: .successDark
        case .failure: .errorMain
        }
    }
}
