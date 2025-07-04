import Foundation
import Identity
import NFCPassportReader
import UIKit
import Web3

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
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var isExpired: Bool {
        if let expiryDate = try? DateUtil.parsePassportDate(documentExpiryDate) {
            return expiryDate < Date()
        } else {
            return true
        }
    }
    
    var isOver18: Bool {
        if let dob = try? DateUtil.parsePassportDate(dateOfBirth, true) {
            return Calendar.current.dateComponents([.year], from: dob, to: Date()).year! >= 18
        } else {
            return false
        }
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
                    from: DateUtil.parsePassportDate(dateOfBirth, true),
                    to: Date()
                ).year!
            )
        } catch {
            return "–"
        }
    }
    
    var displayedFirstName: String {
        firstName.isEmpty ? fullName.components(separatedBy: " ").first ?? "" : firstName
    }
    
    var displayedLastName: String {
        let lastNameParts = fullName.components(separatedBy: " ").dropFirst()
        return lastNameParts.isEmpty ? lastName : lastNameParts.joined(separator: " ")
    }
    
    var encapsulatedContentSize: Int {
        let sod = try? SOD([UInt8](self.sod))
        
        return ((try? sod?.getEncapsulatedContent())?.count ?? 0) * 8
    }
    
    func getDG15PublicKeyPEM() throws -> Data {
        if dg15.isEmpty {
            return Data()
        }
        
        guard let dg15 = try? DataGroup15([UInt8](dg15)) else {
            return Data()
        }
        
        var pubkey: OpaquePointer
        if let rsaPublicKey = dg15.rsaPublicKey {
            pubkey = rsaPublicKey
        } else if let ecdsaPublicKey = dg15.ecdsaPublicKey {
            pubkey = ecdsaPublicKey
        } else {
            throw PassportError.missingPublicKey
        }
        
        guard let pubKeyPem = OpenSSLUtils.pubKeyToPEM(pubKey: pubkey).data(using: .utf8) else {
            throw PassportError.invalidPublicKeyFormat
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
            documentType: model.documentType.replacingOccurrences(of: "<", with: ""),
            issuingAuthority: PassportUtils.normalizeNationality(model.issuingAuthority),
            documentNumber: model.documentNumber,
            documentExpiryDate: model.documentExpiryDate,
            dateOfBirth: model.dateOfBirth,
            nationality: PassportUtils.normalizeNationality(model.nationality),
            dg1: Data(dg1),
            dg15: Data(dg15),
            sod: Data(sod),
            signature: Data(model.activeAuthenticationSignature)
        )
    }
    
    func getStardartalizedDocumentType() -> String {
        guard let dg1 = try? DataGroup1([UInt8](dg1)) else { return "" }
        
        guard let documentType = dg1.elements["5F03"] else { return "" }
        
        let normalizedDocumentType = documentType
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: "O", with: "")
        
        switch normalizedDocumentType {
        case "ID":
            return "TD1"
        case "P":
            return "TD3"
        default:
            return ""
        }
    }
    
    func getSlaveSodCertificatePem() throws -> Data {
        let sod = try SOD([UInt8](sod))
        
        guard let cert = try OpenSSLUtils.getX509CertificatesFromPKCS7(pkcs7Der: Data(sod.pkcs7CertificateData)).first else {
            throw PassportError.missingSlaveCertificate
        }
        
        return cert.certToPEM().data(using: .utf8) ?? Data()
    }
    
    func getCertificateSmtProof(_ slaveCertPem: Data) async throws -> SMTProof {
        let certificatesSMTAddress = try EthereumAddress(hex: ConfigManager.shared.contracts.certificatesSmtAddress, eip55: false)
        let certificatesSMTContract = try PoseidonSMT(contractAddress: certificatesSMTAddress)
        
        let x509Utils = IdentityX509Util()
        let slaveCertificateIndex = try x509Utils.getSlaveCertificateIndex(slaveCertPem, mastersPem: Certificates.ICAO)

        return try await certificatesSMTContract.getProof(slaveCertificateIndex)
    }
    
    func getSod() throws -> SOD {
        return try SOD([UInt8](sod))
    }
    
    func serialize() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

enum PassportProcessingStatus: Int, Equatable {
    case processing, success, failure
}

enum PassportError: Error {
    case missingPublicKey
    case missingSlaveCertificate
    case invalidPublicKeyFormat
    
    var localizedDescription: String {
        switch self {
        case .missingPublicKey:
            return "Public key is missing"
        case .missingSlaveCertificate:
            return "Slave certificate in SOD is missing"
        case .invalidPublicKeyFormat:
            return "Invalid public key format"
        }
    }
}
