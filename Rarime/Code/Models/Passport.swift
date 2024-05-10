import UIKit
import Foundation
import NFCPassportReader

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
    let dg1: Data
    let dg15: Data
    let sod: Data
    let signature: Data
    
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
    
    var encapsulatedContentSize: Int {
        let sod = try? SOD([UInt8](self.sod))
        
        return ((try? sod?.getEncapsulatedContent())?.count ?? 0) * 8
    }

    static func fromNFCPassportModel(_ model: NFCPassportModel) -> Passport? {
        guard
            let dg1 = model.getDataGroup(.DG1),
            let dg15 = model.getDataGroup(.DG15),
            let sod = model.getDataGroup(.SOD)
        else {
            return nil
        }
        
        return Passport(
            firstName: model.firstName,
            lastName: model.lastName,
            gender: model.gender,
            passportImageRaw: model.passportImage?
                .pngData()?
                .base64EncodedString(options: .endLineWithLineFeed),
            documentType: "P",
            issuingAuthority: model.issuingAuthority,
            documentNumber: model.documentNumber,
            documentExpiryDate: model.documentExpiryDate,
            dateOfBirth: model.dateOfBirth,
            nationality: model.nationality,
            dg1: Data(dg1.data),
            dg15: Data(dg15.data),
            sod: Data(sod.data),
            signature: Data(model.activeAuthenticationSignature)
        )
    }
}
