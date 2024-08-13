import Foundation

import Alamofire
import Foundation
import ZipArchive
import CoreData

enum RegisteredCircuitData: String {
    case registerIdentityUniversalRSA2048 = "registerIdentityUniversalRSA2048"
    case registerIdentityUniversalRSA4096 = "registerIdentityUniversalRSA4096"
}

class CircuitDataManager: ObservableObject {
    static let saveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "circuitsData", directoryHint: .isDirectory)
    
    static let shared = CircuitDataManager()

    let circuitDataURLs: [String: URL]

    init() {
        self.circuitDataURLs = ConfigManager.shared.circuitData.circuitDataURLs
    }
    
    func retriveCircuitData(
        _ circuitName: RegisteredCircuitData,
        _ downloadProgress: @escaping (String) -> Void = { _ in }
    ) async throws -> CircuitData {
        if !AppUserDefaults.shared.isCircuitsStorageCleared {
            try? FileManager.default.removeItem(at: CircuitDataManager.saveDirectory)
            
            AppUserDefaults.shared.isCircuitsStorageCleared = true
        }
        
        guard let circuitDataURL = circuitDataURLs[circuitName.rawValue] else {
            throw "Circuit data URL not found"
        }
        
        if let circuitData = try retriveCircuitDataFromCache(circuitName.rawValue) {
            return circuitData
        }
        
        let fileUrl = try await AF.download(circuitDataURL)
            .downloadProgress { progress in
                let currentDownloadedMb = String(format: "%.1f", Double(progress.completedUnitCount)/1000/1000)
                let totalDownloadedMb = String(format: "%.1f", Double(progress.totalUnitCount)/1000/1000)
                
                downloadProgress("Downloading circuit data: \(currentDownloadedMb)/\(totalDownloadedMb) MB")
            }
            .serializingDownloadedFileURL()
            .result
            .get()
        
        let archivePath = fileUrl.path()
        let unarchivePath = CircuitDataManager.saveDirectory.path()
        
        downloadProgress("Unarchiving circuit data")
        
        SSZipArchive.unzipFile(atPath: archivePath, toDestination: unarchivePath)
        
        downloadProgress("Circuit data unarchived")
        
        guard let circuitData = try retriveCircuitDataFromCache(circuitName.rawValue) else {
            throw "Failed to retrive circuit data from cache"
        }
        
        return circuitData
    }
    
    func retriveCircuitDataFromCache(_ circuitName: String) throws -> CircuitData? {
        let circuitDatPath = CircuitDataManager.saveDirectory.appending(path: "\(circuitName)-download/\(circuitName).dat")
        let circuitZkeyPath = CircuitDataManager.saveDirectory.appending(path: "\(circuitName)-download/circuit_final.zkey")
        
        let fm = FileManager.default
        
        guard
            let circuitDat = fm.contents(atPath: circuitDatPath.path()),
            let circuitZkey = fm.contents(atPath: circuitZkeyPath.path())
        else {
            return nil
        }
        
        return CircuitData(circutDat: circuitDat, circuitZkey: circuitZkey)
    }
}

struct CircuitData {
    let circutDat: Data
    let circuitZkey: Data
}
