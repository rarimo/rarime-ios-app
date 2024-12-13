import Alamofire
import Foundation

class LightRegistrationService {
    let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func register(_ passport: Passport, _ zkProof: ZkProof) async throws -> VerifySodResponse {
        var requestURL = url
        requestURL.append(path: "integrations/incognito-light-registrator/v1/register")

        let sod = try passport.getSod()

        let signedAttributes = try sod.getSignedAttributes()
        let encapsulatedContent = try sod.getEncapsulatedContent()
        var signature = try sod.getSignature()

        let certPem = try passport.getSlaveSodCertificatePem()

        guard let encapsulatedContentDigestAlgorithm = try passport.getEncapsulatedContentDigestAlgorithm(sod) else {
            throw "invalid encapsulated content digest algorithm"
        }

        let sodSignatureAlgorithmName = try sod.getSignatureAlgorithm().lowercased()

        var signatureAlgorithm: String
        if sodSignatureAlgorithmName.contains("rsassapss") {
            signatureAlgorithm = "RSA-PSS"
        } else if sodSignatureAlgorithmName.contains("ecdsa") {
            signatureAlgorithm = "ECDSA"

            signature = try CryptoUtils.decodeECDSASignatureFromASN1(signature)
        } else if sodSignatureAlgorithmName.contains("rsa") {
            signatureAlgorithm = "RSA"
        } else {
            throw "invalid signature algorithm"
        }

        let request = VerifySodRequest(
            data: VerifySodRequestData(
                id: "",
                type: "register",
                attributes: VerifySodRequestAttributes(
                    zkProof: zkProof,
                    documentSod: VerifySodRequestDocumentSod(
                        hashAlgorithm: encapsulatedContentDigestAlgorithm.rawValue.uppercased(),
                        signatureAlgorithm: signatureAlgorithm,
                        signedAttributes: signedAttributes.fullHex,
                        signature: signature.fullHex,
                        aaSignature: passport.signature.fullHex,
                        encapsulatedContent: encapsulatedContent.fullHex,
                        pemFile: certPem.utf8,
                        dg15: passport.dg15.fullHex
                    )
                )
            )
        )

        let response = try await AF.request(
            requestURL,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
        .validate(OpenApiError.catchInstance)
        .serializingDecodable(VerifySodResponse.self)
        .result
        .get()

        return response
    }
}

struct VerifySodRequest: Codable {
    let data: VerifySodRequestData
}

struct VerifySodRequestData: Codable {
    let id, type: String
    let attributes: VerifySodRequestAttributes
}

struct VerifySodRequestAttributes: Codable {
    let zkProof: ZkProof
    let documentSod: VerifySodRequestDocumentSod

    enum CodingKeys: String, CodingKey {
        case zkProof = "zk_proof"
        case documentSod = "document_sod"
    }
}

struct VerifySodRequestDocumentSod: Codable {
    let hashAlgorithm, signatureAlgorithm, signedAttributes, signature: String
    let aaSignature, encapsulatedContent, pemFile, dg15: String

    enum CodingKeys: String, CodingKey {
        case hashAlgorithm = "hash_algorithm"
        case signatureAlgorithm = "signature_algorithm"
        case signedAttributes = "signed_attributes"
        case signature
        case aaSignature = "aa_signature"
        case encapsulatedContent = "encapsulated_content"
        case pemFile = "pem_file"
        case dg15
    }
}

struct VerifySodResponse: Codable {
    let data: VerifySodResponseData
}

struct VerifySodResponseData: Codable {
    let id, type: String
    let attributes: VerifySodResponseAttributes
}

struct VerifySodResponseAttributes: Codable {
    let passportHash, publicKey, signature, verifier: String

    enum CodingKeys: String, CodingKey {
        case passportHash = "passport_hash"
        case publicKey = "public_key"
        case signature, verifier
    }
}
