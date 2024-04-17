//
//  Passport.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 03.04.2024.
//

import Foundation
import NFCPassportReader
import UIKit

struct Passport {
    var firstName: String
    var lastName: String
    var gender: String
    var passportImage: UIImage?
    var documentType: String
    var issuingAuthority: String
    var documentNumber: String
    var documentExpiryDate: String
    var dateOfBirth: String
    var nationality: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var ageString: String {
        do {
            return try String(
                Calendar.current.dateComponents(
                    [.year],
                    from: DateUtil.parsePassportDate(dateOfBirth),
                    to: Date()
                ).year!
            )
        } catch {
            return "–"
        }
    }

    static func fromNFCPassportModel(_ model: NFCPassportModel) -> Passport {
        Passport(
            firstName: model.firstName,
            lastName: model.lastName,
            gender: model.gender,
            passportImage: model.passportImage,
            documentType: model.documentSubType,
            issuingAuthority: model.issuingAuthority,
            documentNumber: model.documentNumber,
            documentExpiryDate: model.documentExpiryDate,
            dateOfBirth: model.dateOfBirth,
            nationality: model.nationality
        )
    }
}
