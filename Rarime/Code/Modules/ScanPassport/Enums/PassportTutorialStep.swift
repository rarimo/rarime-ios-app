import Foundation

enum PassportTutorialStep: Int, CaseIterable {
    case removeCase, scanYourPassport, readingPassportData
    
    var title: LocalizedStringResource {
        switch self {
        case .removeCase: return "Remove case"
        case .scanYourPassport: return "Scan your Passport"
        case .readingPassportData: return "NFC Reader"
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .removeCase: return "Make sure you remove the case from the device"
        case .scanYourPassport: return "Scan your passport’s first page inside the border"
        case .readingPassportData: return "Place your passport cover to the back of your phone"
        }
    }

    var video: URL {
        switch self {
        case .removeCase: return Videos.removeCase
        case .scanYourPassport: return Videos.scanMrzPassport
        case .readingPassportData: return Videos.readNfcPassport
        }
    }
    
    var buttonText: LocalizedStringResource {
        switch self {
        case .removeCase: return "Next"
        case .scanYourPassport: return "Next"
        case .readingPassportData: return "Let's Scan"
        }
    }
}
