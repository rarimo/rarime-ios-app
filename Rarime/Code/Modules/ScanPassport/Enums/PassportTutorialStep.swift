import Foundation

enum PassportTutorialStep: Int, CaseIterable {
    case removeCase, scanMrz, readNfc
    
    var title: LocalizedStringResource {
        switch self {
        case .removeCase: return "Remove Case"
        case .scanMrz: return "Scan Your Passport"
        case .readNfc: return "NFC Reader"
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .removeCase: return "Make sure you remove the case from the device"
        case .scanMrz: return "Scan your passport’s first page inside the border"
        case .readNfc: return "Place your passport cover to the back of your phone"
        }
    }

    var video: URL {
        switch self {
        case .removeCase: return Videos.removeCase
        case .scanMrz: return Videos.scanMrz
        case .readNfc: return Videos.readNfc
        }
    }
    
    var buttonText: LocalizedStringResource {
        switch self {
        case .removeCase, .scanMrz: return "Next"
        case .readNfc: return "Let's Scan"
        }
    }
}
