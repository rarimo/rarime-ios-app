import Foundation

import Alamofire
import CoreData
import Foundation
import ZipArchive

enum RegisteredCircuitData: String {
    case registerIdentity_1_256_3_5_576_248_NA
    case registerIdentity_1_256_3_6_576_248_1_2432_5_296
    case registerIdentity_2_256_3_6_336_264_21_2448_6_2008
    case registerIdentity_21_256_3_7_336_264_21_3072_6_2008
    case registerIdentity_1_256_3_6_576_264_1_2448_3_256
    case registerIdentity_2_256_3_6_336_248_1_2432_3_256
    case registerIdentity_2_256_3_6_576_248_1_2432_3_256
    case registerIdentity_11_256_3_3_576_248_1_1184_5_264
    case registerIdentity_12_256_3_3_336_232_NA
    case registerIdentity_1_256_3_4_336_232_1_1480_5_296
    case registerIdentity_1_256_3_4_600_248_1_1496_3_256
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
                
                downloadProgress("\(currentDownloadedMb)/\(totalDownloadedMb) MB")
            }
            .serializingDownloadedFileURL()
            .result
            .get()
        
        let archivePath = fileUrl.path()
        let unarchivePath = CircuitDataManager.saveDirectory.path()
        
        SSZipArchive.unzipFile(atPath: archivePath, toDestination: unarchivePath)
        
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
