import Foundation
import SwiftUI

enum PassportIdentifier: String, CaseIterable {
    case nationality, documentId, expiryDate, birthDate
}

extension PassportIdentifier {
    var title: String {
        switch self {
        case .nationality: String(localized: "Nationality")
        case .documentId: String(localized: "Document ID")
        case .expiryDate: String(localized: "Expiry date")
        case .birthDate: String(localized: "Birth date")
        }
    }
}

extension PassportIdentifier {
    var order: Int {
        switch self {
        case .nationality: 0
        case .documentId: 1
        case .expiryDate: 2
        case .birthDate: 3
        }
    }
}

extension PassportIdentifier {
    func getPassportValue(from passport: Passport) -> String {
        switch self {
        case .nationality: return Country.fromISOCode(passport.nationality).flag
        case .documentId: return passport.documentNumber
        case .expiryDate:
            let date = try? DateUtil.parsePassportDate(passport.documentExpiryDate)
            return date == nil ? "–" : DateUtil.mdyDateFormatter.string(from: date!)
        case .birthDate:
            let date = try? DateUtil.parsePassportDate(passport.dateOfBirth)
            return date == nil ? "–" : DateUtil.mdyDateFormatter.string(from: date!)
        }
    }
}

extension PassportIdentifier {
    var titleStub: String {
        switch self {
        case .nationality: "•••••••••"
        case .documentId: "•••••••••••"
        case .expiryDate: "•••••••••"
        case .birthDate: "•••••••••"
        }
    }
}

extension PassportIdentifier {
    var valueStub: String {
        switch self {
        case .nationality: "•••"
        case .documentId: "••••••••"
        case .expiryDate: "••••••"
        case .birthDate: "••••••"
        }
    }
}
