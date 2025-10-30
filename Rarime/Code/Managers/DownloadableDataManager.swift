import Alamofire
import CoreData
import Foundation
import ZipArchive

enum RegisteredCircuitData: String {
    
    case registerIdentityLight160
    case registerIdentityLight224
    case registerIdentityLight256
    case registerIdentityLight384
    case registerIdentityLight512
    
    case registerIdentity_14_256_3_4_336_64_1_1480_5_296
    
    case registerIdentity_1_256_3_6_336_560_1_2744_4_256
    case registerIdentity_20_256_3_5_336_72_NA
    
    case registerIdentity_4_160_3_3_336_216_1_1296_3_256
    case registerIdentity_20_160_3_3_736_200_NA
}

enum RegisteredZkey: String {
    case likeness
}

enum RegisteredNoirCircuitData: String {
    case registerIdentity_2_256_3_6_336_264_21_2448_6_2008
    case registerIdentity_2_256_3_6_336_248_1_2432_3_256
    case registerIdentity_20_256_3_3_336_224_NA
    
    case registerIdentity_10_256_3_3_576_248_1_1184_5_264
    case registerIdentity_1_256_3_4_600_248_1_1496_3_256
    case registerIdentity_21_256_3_3_576_232_NA
    
    case registerIdentity_21_256_3_4_576_232_NA
    
    case registerIdentity_11_256_3_4_336_232_1_1480_4_256
    case registerIdentity_2_256_3_6_576_248_1_2432_3_256
    case registerIdentity_3_512_3_3_336_264_NA
    
    case registerIdentity_1_256_3_5_336_248_1_2120_4_256
    case registerIdentity_2_256_3_4_336_232_1_1480_4_256
    case registerIdentity_2_256_3_4_336_248_NA
    
    case registerIdentity_14_256_3_3_576_240_NA
    case registerIdentity_14_256_3_4_576_248_1_1496_3_256
    case registerIdentity_20_160_3_2_576_184_NA
    
    case registerIdentity_1_256_3_5_576_248_NA
    case registerIdentity_1_256_3_6_576_264_1_2448_3_256
    case registerIdentity_20_160_3_3_576_200_NA
    
    case registerIdentity_11_256_3_3_576_248_NA
    case registerIdentity_23_160_3_3_576_200_NA
    case registerIdentity_3_256_3_4_600_248_1_1496_3_256
    
    case registerIdentity_20_256_3_5_336_248_NA
    case registerIdentity_24_256_3_4_336_248_NA
    case registerIdentity_6_160_3_3_336_216_1_1080_3_256
    
    case registerIdentity_11_256_3_5_576_248_NA
    case registerIdentity_14_256_3_4_336_232_1_1480_5_296
    case registerIdentity_1_256_3_4_576_232_1_1480_3_256
    
    case registerIdentity_1_256_3_5_336_248_1_2120_3_256
    case registerIdentity_7_160_3_3_336_216_1_1080_3_256

    case registerIdentity_8_160_3_3_336_216_1_1080_3_256

    case registerIdentity_3_256_3_3_576_248_NA

    case registerIdentity_25_384_3_3_336_264_1_2024_3_296

    case registerIdentity_28_384_3_3_576_264_24_2024_4_2792
    case registerIdentity_1_256_3_6_576_248_1_2432_5_296
    case registerIdentity_25_384_3_3_336_248_NA

    case registerIdentity_1_160_3_3_576_200_NA
    case registerIdentity_1_256_3_3_576_248_NA
    case registerIdentity_1_256_3_4_336_232_1_1480_5_296

    case registerIdentity_1_256_3_6_336_248_1_2744_4_256
    case registerIdentity_2_256_3_6_336_264_1_2448_3_256
    case registerIdentity_3_160_3_3_336_200_NA

    case registerIdentity_3_160_3_4_576_216_1_1512_3_256
    case registerIdentity_11_256_3_2_336_216_NA
    case registerIdentity_11_256_3_3_336_248_NA

    case registerIdentity_11_256_3_3_576_240_1_864_5_264
    case registerIdentity_11_256_3_3_576_248_1_1184_5_264
    case registerIdentity_11_256_3_4_584_248_1_1496_4_256

    case registerIdentity_11_256_3_5_576_248_1_1808_5_296
    case registerIdentity_12_256_3_3_336_232_NA
    case registerIdentity_15_512_3_3_336_248_NA

    case registerIdentity_21_256_3_3_336_232_NA
    case registerIdentity_21_256_3_5_576_232_NA
    case registerIdentity_24_256_3_4_336_232_NA

    case registerIdentity_11_256_3_5_576_248_1_1808_4_256
    
    case registerIdentity_2_256_3_5_336_248_22_1808_7_2408
    case registerIdentity_1_256_3_6_336_248_1_2432_3_256
    case registerIdentity_25_384_3_5_576_248_20_3768_3_2008
    
    case registerIdentity_11_256_3_4_576_248_1_1496_5_296
    case registerIdentity_1_256_3_4_336_248_1_1496_4_256
    
    case registerIdentity_1_256_3_5_344_232_NA
    case registerIdentity_21_256_3_7_336_264_21_3072_6_2008
}

enum RegisteredDownloadableFiles: String {
    case faceRecognitionTFLite
    
    // If you decided to remove ".dat", well, good luck to debug crash buddy
    case ultraPlonkTrustedSetup = "ultraPlonkTrustedSetup.dat"
}

class DownloadableDataManager: ObservableObject {
    static let saveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "circuitsData", directoryHint: .isDirectory)
    static let noirSaveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "noirCircuitsData", directoryHint: .isDirectory)
    static let zkeySaveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "zkeys", directoryHint: .isDirectory)
    static let downloadablesSaveDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "downloadbles", directoryHint: .isDirectory)
    
    static let shared = DownloadableDataManager()

    func retriveCircuitData(
        _ circuitName: RegisteredCircuitData,
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> CircuitData {
        if !AppUserDefaults.shared.isCircuitsStorageCleared {
            clearCache()
            
            AppUserDefaults.shared.isCircuitsStorageCleared = true
        }
        
        guard let circuitDataURL = CIRCUIT_DATA_URLS[circuitName.rawValue] else {
            throw DownloadableDataManagerError.circuitDataNotFound(circuitName.rawValue)
        }
        
        if let circuitData = try retriveCircuitDataFromCache(circuitName.rawValue) {
            return circuitData
        }
        
        let fileUrl = try await AF.download(circuitDataURL)
            .downloadProgress { progress in
                downloadProgress(progress)
            }
            .serializingDownloadedFileURL()
            .result
            .get()
        
        let archivePath = fileUrl.path()
        let unarchivePath = DownloadableDataManager.saveDirectory.path()
        
        SSZipArchive.unzipFile(atPath: archivePath, toDestination: unarchivePath)
        
        guard let circuitData = try retriveCircuitDataFromCache(circuitName.rawValue) else {
            throw DownloadableDataManagerError.cacheRetrievalError(circuitName.rawValue)
        }
        
        return circuitData
    }
    
    func retriveCircuitDataFromCache(_ circuitName: String) throws -> CircuitData? {
        let circuitDatPath = DownloadableDataManager.saveDirectory.appending(path: "\(circuitName)-download/\(circuitName).dat")
        let circuitZkeyPath = DownloadableDataManager.saveDirectory.appending(path: "\(circuitName)-download/circuit_final.zkey")
                
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
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> URL {
        return try await retriveFilePath(
            circuitDataName.rawValue,
            NOIR_CIRCUIT_DATA_URLS,
            DownloadableDataManager.noirSaveDirectory,
            downloadProgress
        )
    }
    
    func retriveZkeyPath(
        _ zkeyName: RegisteredZkey,
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> URL {
        return try await retriveFilePath(
            zkeyName.rawValue,
            ZKEY_URLS,
            DownloadableDataManager.zkeySaveDirectory,
            downloadProgress
        )
    }
    
    func retriveDownloadbleFilePath(
        _ fileName: RegisteredDownloadableFiles,
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> URL {
        return try await retriveFilePath(
            fileName.rawValue,
            DOWNLOADABLE_FILE_URLS,
            DownloadableDataManager.downloadablesSaveDirectory,
            downloadProgress
        )
    }
    
    func retriveFilePath(
        _ fileName: String,
        _ fileURLsMap: [String: URL],
        _ saveDirectory: URL,
        _ downloadProgress: @escaping (Progress) -> Void = { _ in }
    ) async throws -> URL {
        if !AppUserDefaults.shared.isCircuitsStorageCleared {
            clearCache()
            
            AppUserDefaults.shared.isCircuitsStorageCleared = true
        }
        
        if let filePath = try retriveFilePathFromCache(fileName, saveDirectory) {
            return filePath
        }
        
        guard let fileURL = fileURLsMap[fileName] else {
            throw DownloadableDataManagerError.fileNotFound(fileName)
        }

        let downloadedfileUrl = try await AF.download(fileURL)
            .downloadProgress { progress in
                downloadProgress(progress)
            }
            .serializingDownloadedFileURL()
            .result
            .get()
        
        if !FileManager.default.fileExists(atPath: saveDirectory.path()) {
            try FileManager.default.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        }
        
        let moveDirectory = saveDirectory.appending(path: fileName)
        
        try FileManager.default.moveItem(atPath: downloadedfileUrl.path(), toPath: moveDirectory.path())
        
        guard let filePath = try retriveFilePathFromCache(fileName, saveDirectory) else {
            throw DownloadableDataManagerError.cacheRetrievalError(fileName)
        }
        
        return filePath
    }
    
    func retriveFilePathFromCache(_ fileName: String, _ saveDirectory: URL) throws -> URL? {
        let filePath = saveDirectory.appending(path: fileName)
        
        if !FileManager.default.fileExists(atPath: filePath.path()) {
            return nil
        }
        
        return filePath
    }
    
    func clearCache() {
        try? FileManager.default.removeItem(at: DownloadableDataManager.saveDirectory)
        try? FileManager.default.removeItem(at: DownloadableDataManager.noirSaveDirectory)
        try? FileManager.default.removeItem(at: DownloadableDataManager.zkeySaveDirectory)
        try? FileManager.default.removeItem(at: DownloadableDataManager.downloadablesSaveDirectory)
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

enum DownloadableDataManagerError: Error {
    case circuitDataNotFound(String)
    case fileNotFound(String)
    case cacheRetrievalError(String)
    
    var localizedDescription: String {
        switch self {
        case .circuitDataNotFound(let circuitName):
            return "Circuit data for \(circuitName) not found."
        case .fileNotFound(let fileName):
            return "File \(fileName) not found."
        case .cacheRetrievalError(let fileName):
            return "Cache retrieval error for \(fileName)."
        }
    }
}
