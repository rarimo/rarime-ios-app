import Foundation

enum PassportScanStep: Int, CaseIterable {
    case scanYourPassport, readingPassportData

    var title: LocalizedStringResource {
        switch self {
        case .scanYourPassport: return "Scan your Passport"
        case .readingPassportData: return "NFC Reader"
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .scanYourPassport: return "Scan your passport’s first page inside the border"
        case .readingPassportData: return "Place your passport cover to the back of your phone"
        }
    }

    var video: URL {
        switch self {
        case .scanYourPassport: return Videos.scanMrzPassport
        case .readingPassportData: return Videos.readNfcPassport
        }
    }
    
    var buttonText: LocalizedStringResource {
        switch self {
        case .scanYourPassport: return "Next"
        case .readingPassportData: return "Let's Scan"
        }
    }
}
