import Alamofire
import CoreData
import Foundation
import ZipArchive

enum RegisteredCircuitData: String {
    case registerIdentity_1_256_3_5_576_248_NA
    case registerIdentity_1_256_3_6_576_248_1_2432_5_296
    
    case registerIdentity_21_256_3_7_336_264_21_3072_6_2008
    case registerIdentity_1_256_3_6_576_264_1_2448_3_256
    
    case registerIdentity_2_256_3_6_576_248_1_2432_3_256
    case registerIdentity_11_256_3_3_576_248_1_1184_5_264
    case registerIdentity_12_256_3_3_336_232_NA
    
    case registerIdentity_1_256_3_4_336_232_1_1480_5_296
    case registerIdentity_1_256_3_4_600_248_1_1496_3_256
    case registerIdentity_1_160_3_3_576_200_NA
    
    case registerIdentity_21_256_3_3_336_232_NA
    case registerIdentity_24_256_3_4_336_232_NA
    case registerIdentity_1_256_3_3_576_248_NA
    
    case registerIdentity_21_256_3_3_576_232_NA
    case registerIdentity_11_256_3_5_576_248_1_1808_4_256
    case registerIdentity_10_256_3_3_576_248_1_1184_5_264
    
    case registerIdentityLight160
    case registerIdentityLight224
    case registerIdentityLight256
    case registerIdentityLight384
    case registerIdentityLight512
    
    case registerIdentity_2_256_3_6_336_264_1_2448_3_256
    case registerIdentity_3_160_3_3_336_200_NA
    case registerIdentity_3_160_3_4_576_216_1_1512_3_256
    
    case registerIdentity_11_256_3_3_576_240_1_864_5_264
    case registerIdentity_21_256_3_4_576_232_NA
    case registerIdentity_11_256_3_5_576_248_1_1808_5_296
    
    case registerIdentity_11_256_3_3_336_248_NA
    case registerIdentity_14_256_3_4_336_64_1_1480_5_296
    case registerIdentity_21_256_3_5_576_232_NA
    
    case registerIdentity_1_256_3_6_336_560_1_2744_4_256
    case registerIdentity_1_256_3_6_336_248_1_2744_4_256
    case registerIdentity_20_256_3_5_336_72_NA
    
    case registerIdentity_4_160_3_3_336_216_1_1296_3_256
    case registerIdentity_15_512_3_3_336_248_NA
    case registerIdentity_20_160_3_3_736_200_NA
}

enum RegisteredNoirCircuitData: String {
    // If you decided to remove ".dat", well, good luck to debug crash buddy
    case trustedSetup = "trustedSetup.dat"
    
    case registerIdentity_2_256_3_6_336_264_21_2448_6_2008
    case registerIdentity_2_256_3_6_336_248_1_2432_3_256
    case registerIdentity_20_256_3_3_336_224_NA
}

class CircuitDataManager: ObservableObject {
    static let saveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "circuitsData", directoryHint: .isDirectory)
    static let noirSaveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "noirCircuitsData", directoryHint: .isDirectory)
    
    static let shared = CircuitDataManager()

    let circuitDataURLs: [String: URL]
    let noirCircuitDataURLs: [String: URL]

    init() {
        self.circuitDataURLs = ConfigManager.shared.circuitData.circuitDataURLs
        self.noirCircuitDataURLs = ConfigManager.shared.noirCircuitData.noirCircuitDataURLs
    }
    
    func retriveCircuitData(
        _ circuitName: RegisteredCircuitData,
        _ downloadProgress: @escaping (Double) -> Void = { _ in }
    ) async throws -> CircuitData {
        if !AppUserDefaults.shared.isCircuitsStorageCleared {
            clearCache()
            
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
                downloadProgress(progress.fractionCompleted)
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
                
        if
            !FileManager.default.fileExists(atPath: circuitDatPath.path()) ||
            !FileManager.default.fileExists(atPath: circuitZkeyPath.path())
        {
            return nil
        }
        
        return CircuitData(
            circutDatPath: circuitDatPath.path(),
            circuitZkeyPath: circuitZkeyPath.path()
        )
    }
    
    func retriveNoirCircuitDataPath(
        _ circuitDataName: RegisteredNoirCircuitData,
        _ downloadProgress: @escaping (Double) -> Void = { _ in }
    ) async throws -> URL {
        if !AppUserDefaults.shared.isCircuitsStorageCleared {
            clearCache()
            
            AppUserDefaults.shared.isCircuitsStorageCleared = true
        }
        
        if let circuitData = try retriveNoirCircuitDataPathFromCache(circuitDataName.rawValue) {
            return circuitData
        }
        
        let noirCircuitDataURL: URL
        if circuitDataName == .trustedSetup {
            noirCircuitDataURL = ConfigManager.shared.noirCircuitData.noirTrustedSetupURL
        } else {
            guard let selectedCircuitDataURL = noirCircuitDataURLs[circuitDataName.rawValue] else {
                throw "Circuit data URL not found"
            }
            
            noirCircuitDataURL = selectedCircuitDataURL
        }
        
        let fileUrl = try await AF.download(noirCircuitDataURL)
            .downloadProgress { progress in
                downloadProgress(progress.fractionCompleted)
            }
            .serializingDownloadedFileURL()
            .result
            .get()
        
        if !FileManager.default.fileExists(atPath: CircuitDataManager.noirSaveDirectory.path()) {
            try FileManager.default.createDirectory(at: CircuitDataManager.noirSaveDirectory, withIntermediateDirectories: true)
        }
        
        let moveDirectory = CircuitDataManager.noirSaveDirectory.appending(path: "\(circuitDataName.rawValue)")
        
        try FileManager.default.moveItem(atPath: fileUrl.path(), toPath: moveDirectory.path())
        
        guard let circuitData = try retriveNoirCircuitDataPathFromCache(circuitDataName.rawValue) else {
            throw "Failed to retrive circuit data path from cache"
        }
        
        return circuitData
    }
    
    func retriveNoirCircuitDataPathFromCache(_ circuitDataName: String) throws -> URL? {
        let circuitDataPath = CircuitDataManager.noirSaveDirectory.appending(path: "\(circuitDataName)")
                
        if !FileManager.default.fileExists(atPath: circuitDataPath.path()) {
            return nil
        }
        
        return circuitDataPath
    }
    
    func clearCache() {
        try? FileManager.default.removeItem(at: CircuitDataManager.saveDirectory)
        try? FileManager.default.removeItem(at: CircuitDataManager.noirSaveDirectory)
    }
}

struct CircuitData {
    let circutDatPath: String
    let circuitZkeyPath: String
    
    var circuitDat: Data {
        FileManager.default.contents(atPath: circutDatPath) ?? Data()
    }
    
    var circuitZkey: Data {
        FileManager.default.contents(atPath: circuitZkeyPath) ?? Data()
    }
}
