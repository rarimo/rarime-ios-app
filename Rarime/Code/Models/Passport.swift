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
    
    func getDG15PublicKeyPEM() throws -> Data {
        let dg15 = try DataGroup15([UInt8](dg15))
        
        var pubkey: OpaquePointer
        if let rsaPublicKey = dg15.rsaPublicKey {
            pubkey = rsaPublicKey
        } else if let ecdsaPublicKey = dg15.ecdsaPublicKey {
            pubkey = ecdsaPublicKey
        } else {
            throw "Public key is missing"
        }
        
        guard let pubKeyPem = OpenSSLUtils.pubKeyToPEM(pubKey: pubkey).data(using: .utf8) else {
            throw "Failed to convert public key to PEM"
        }
        
        return pubKeyPem
    }

    static func fromNFCPassportModel(_ model: NFCPassportModel) -> Passport? {
        let dg1 = model.getDataGroup(.DG1)?.data ?? []
        let dg15 = model.getDataGroup(.DG15)?.data ?? []
        let sod = model.getDataGroup(.SOD)?.data ?? []
        
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
            dg1: Data(dg1),
            dg15: Data(dg15),
            sod: Data(sod),
            signature: Data(model.activeAuthenticationSignature)
        )
    }
    
    func serialize() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
