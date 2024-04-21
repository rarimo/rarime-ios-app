import Foundation

class IdentityManager: ObservableObject {
    static let shared = IdentityManager()

    // TODO: Get the private key from keychain
    @Published private(set) var privateKey: String = "d4f1dc5332e5f0263746a31d3563e42ad8bef24a8989d8b0a5ad71f8d5de28a6"

    var did: String {
        // TODO: Get the DID from the private key
        "did:iden3:readonly:tQR6mhrf6jJyYxmc9YZZS6xiyxjG4b4yQh92diTme"
    }

    var formattedDid: String {
        let id = did.replacingOccurrences(of: "did:iden3:readonly:", with: "")
        let startIndex = id.index(id.startIndex, offsetBy: 12)
        let endIndex = id.index(id.endIndex, offsetBy: -12)
        return String(id.prefix(upTo: startIndex) + "..." + id.suffix(from: endIndex))
    }
}
