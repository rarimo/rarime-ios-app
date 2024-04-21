import Foundation
import NFCPassportReader
import UIKit

struct Passport: Codable {
    var firstName: String
    var lastName: String
    var gender: String
    var passportImageRaw: String?
    var documentType: String
    var issuingAuthority: String
    var documentNumber: String
    var documentExpiryDate: String
    var dateOfBirth: String
    var nationality: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case passportImageRaw = "passport_image_raw"
        case documentType = "document_type"
        case issuingAuthority = "issuing_authority"
        case documentNumber = "document_number"
        case documentExpiryDate = "document_expiry_date"
        case dateOfBirth = "date_of_birth"
        case nationality
    }

    init(
        firstName: String,
        lastName: String,
        gender: String,
        passportImageRaw: String?,
        documentType: String,
        issuingAuthority: String,
        documentNumber: String,
        documentExpiryDate: String,
        dateOfBirth: String,
        nationality: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.passportImageRaw = passportImageRaw
        self.documentType = documentType
        self.issuingAuthority = issuingAuthority
        self.documentNumber = documentNumber
        self.documentExpiryDate = documentExpiryDate
        self.dateOfBirth = dateOfBirth
        self.nationality = nationality
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        gender = try container.decode(String.self, forKey: .gender)
        passportImageRaw = try container.decode(String.self, forKey: .passportImageRaw)
        documentType = try container.decode(String.self, forKey: .documentType)
        issuingAuthority = try container.decode(String.self, forKey: .issuingAuthority)
        documentNumber = try container.decode(String.self, forKey: .documentNumber)
        documentExpiryDate = try container.decode(String.self, forKey: .documentExpiryDate)
        dateOfBirth = try container.decode(String.self, forKey: .dateOfBirth)
        nationality = try container.decode(String.self, forKey: .nationality)
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var passportImage: UIImage? {
        guard let passportImageRaw = passportImageRaw else {
            return nil
        }

        if let data = Data(base64Encoded: passportImageRaw, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        } else {
            return nil
        }
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
            passportImageRaw: model.passportImage?
                .pngData()?
                .base64EncodedString(options: .endLineWithLineFeed),
            documentType: model.documentType,
            issuingAuthority: model.issuingAuthority,
            documentNumber: model.documentNumber,
            documentExpiryDate: model.documentExpiryDate,
            dateOfBirth: model.dateOfBirth,
            nationality: model.nationality
        )
    }
}
