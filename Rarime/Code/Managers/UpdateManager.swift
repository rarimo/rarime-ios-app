import Alamofire
import Foundation

class UpdateManager: ObservableObject {
    @Published var isDeprecated: Optional<Bool> = nil
    
    static let shared = UpdateManager()
    
    func isUpdateAvailable() async throws -> Bool {
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return false
        }
        
        guard
            let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String
        else {
            throw "Invalid bundle info"
        }
        
        let response = try await AF.request("https://itunes.apple.com/lookup?bundleId=\(identifier)")
            .serializingDecodable(ITunesLookupResponse.self)
            .result
            .get()
        
        guard let firstResult = response.results.first else {
            throw "response are empty"
        }
        
        return firstResult.version.compare(currentVersion, options: .numeric) == .orderedDescending
    }
    
    func checkForUpdate() async {
        do {
            let isDeprecated = try await isUpdateAvailable()
            
            DispatchQueue.main.async {
                self.isDeprecated = isDeprecated
            }
        } catch {
            DispatchQueue.main.async {
                self.isDeprecated = false
            }
            
            LoggerUtil.common.error("Failed to check for update: \(error, privacy: .public)")
        }
    }
}

struct ITunesLookupResponse: Codable {
    let results: [ITunesLookupResponseResult]
}

struct ITunesLookupResponseResult: Codable {
    let version: String
}
