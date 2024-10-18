import NFCPassportReader
import OpenSSL
import SwiftUI

class NFCScanner {
    private static let customDisplayMessage: (NFCViewDisplayMessage) -> String? = { displayMessage in
        // Forked from NFCViewDisplayMessage
        func drawProgressBar(_ progress: Int) -> String {
            let itemsCount = (progress / 20)
            let full = String(repeating: "🟢 ", count: itemsCount)
            let empty = String(repeating: "⚪️ ", count: 5 - itemsCount)
            return "\(full)\(empty)"
        }
        
        let message: LocalizedStringResource?
        switch displayMessage {
        case .requestPresentPassport:
            message = "Hold your iPhone near an NFC enabled passport.\n"
        case .authenticatingWithPassport(let progress):
            message = "Authenticating with passport...\n\n\(drawProgressBar(progress))"
        case .activeAuthentication:
            message = "Authenticating with passport..."
        case .readingDataGroupProgress(let dataGroup, let progress):
            message = "Reading passport data (\(dataGroup.getName()))...\n\n\(drawProgressBar(progress))"
        case .error(let tagError):
            switch tagError {
            case .TagNotValid: message = "Tag not valid."
            case .MoreThanOneTagFound: message = "More than 1 tag was found. Please present only 1 tag."
            case .ConnectionError: message = "Connection error. Please try again."
            case .InvalidMRZKey: message = "MRZ Key not valid for this document."
            case .ResponseError(let reason, let sw1, let sw2):
                message = "Sorry, there was a problem reading the passport. \(reason). Error codes: [0x\(sw1), 0x\(sw2)]"
            default: message = "Sorry, there was a problem reading the passport. Please try again"
            }
        case .successfulRead:
            message = "Passport read successfully"
        }
        
        return message == nil ? nil : String(localized: message!)
    }
    
    static func scanPassport(
        _ mrzKey: String,
        _ challenge: Data,
        _ useExtendedMode: Bool = true,
        onCompletion: @escaping (Result<Passport, Error>) -> Void
    ) {
        Task { @MainActor in
            var tags: [DataGroupId] = [.DG1, .DG15, .SOD]
            
            #if PRODUCTION
                tags.append(.DG2)
            #endif
            
            do {
                let nfcPassport = try await PassportReader()
                    .readPassport(
                        mrzKey: mrzKey,
                        tags: tags,
                        useExtendedMode: useExtendedMode,
                        customDisplayMessage: customDisplayMessage,
                        activeAuthenticationChallenge: [UInt8](challenge)
                    )
                
                guard let passport = Passport.fromNFCPassportModel(nfcPassport) else { throw "failed to read raw passport data" }
                
                onCompletion(.success(passport))
            } catch {
                onCompletion(.failure(error))
            }
        }
    }
}
