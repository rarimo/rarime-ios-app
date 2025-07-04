import Alamofire
import Foundation

class UpdateManager: ObservableObject {
    @Published var isDeprecated: Optional<Bool> = nil
    @Published var isMaintenance: Bool = false
    
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
            throw UpdateManagerError.invalidBundleInfo
        }
        
        let response = try await AF.request("https://itunes.apple.com/lookup?bundleId=\(identifier)")
            .serializingDecodable(ITunesLookupResponse.self)
            .result
            .get()
        
        guard let firstResult = response.results.first else {
            throw UpdateManagerError.emptyResponse
        }
        
        return firstResult.version.compare(currentVersion, options: .numeric) == .orderedDescending
    }
    
    @MainActor
    func checkMaintenanceMode() async {
        do {
            let points = Points(ConfigManager.shared.general.appApiURL)
            let maintenanceResponse = try await points.getMaintenanceMode()
            
            self.isMaintenance = maintenanceResponse.data.attributes.maintenance
        } catch {
            LoggerUtil.common.error("Failed to check for maintenance: \(error, privacy: .public)")
        }
    }
    
    @MainActor
    func checkForUpdate() async {
        do {
            let isDeprecated = try await isUpdateAvailable()
            
            self.isDeprecated = isDeprecated
        } catch {
            self.isDeprecated = false
            
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

enum UpdateManagerError: Error {
    case invalidBundleInfo
    case emptyResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidBundleInfo:
            return "Invalid bundle info"
        case .emptyResponse:
            return "Response is empty"
        }
    }
}
