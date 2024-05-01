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
            message = "Hold your iPhone near an NFC enabled passport."
        case .activeAuthentication, .authenticatingWithPassport:
            message = "Authenticating with passport..."
        case .readingDataGroupProgress(_, let progress):
            message = "Reading passport data...\n\n\(drawProgressBar(progress))"
        case .error:
            message = "Sorry, there was a problem reading the passport. Please try again"
        case .successfulRead:
            message = "Passport read successfully"
        }
        
        return message == nil ? nil : String(localized: message!)
    }
    
    static func scanPassport(
        _ mrzKey: String,
        _ challenge: Data,
        onCompletion: @escaping (Result<Passport, Error>) -> Void
    ) {
        Task { @MainActor in
            do {
                let nfcPassport = try await PassportReader()
                    .readPassport(
                        mrzKey: mrzKey,
                        tags: [.DG1, .DG2, .DG15, .SOD],
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
