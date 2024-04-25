import Alamofire
import Foundation
import ZipArchive
import CoreData

class CircuitDataManager: ObservableObject {
    static let shared = CircuitDataManager()
    
    let registerIdentityCircuitDataURLs: [URL]
    
    init() {
        let circuitData = ConfigManager.shared.circuitData
        
        self.registerIdentityCircuitDataURLs = circuitData.registerIdentityCircuitDataURLs
    }
    
    func downloadCircuitData(
        _ onFinish: @escaping () -> Void = {},
        _ downloadProgress: @escaping (String) -> Void = { _ in }
    ) async throws {
        downloadProgress("Initializing session")
        
        let registerIdentityMetadataStorageMapData = AppUserDefaults.shared.registerCircuitMetadata
        
        var registerIdentityMetadataStorageMap = try JSONDecoder().decode([Int: RegisterIdentityCircuitMetadataEntry].self, from: registerIdentityMetadataStorageMapData)
        
        for (i, url) in registerIdentityCircuitDataURLs.enumerated() {
            if registerIdentityMetadataStorageMap.contains(where: { (_, metadata) in
                metadata.downloadedFrom == url.path()
            }) {
                downloadProgress("Circuit data \(i+1) is already downloaded")
                
                continue
            }
            
            downloadProgress("Downloading circuit data \(i+1)")
            
            let fileUrl = try await AF.download(url)
                .downloadProgress { progress in
                    let currentDownloadedMb = String(format: "%.1f", Double(progress.completedUnitCount)/1000/1000)
                    let totalDownloadedMb = String(format: "%.1f", Double(progress.totalUnitCount)/1000/1000)
                    
                    downloadProgress("Downloading circuit data \(i+1): \(currentDownloadedMb)/\(totalDownloadedMb) MB")
                }
                .serializingDownloadedFileURL()
                .result
                .get()
            
            downloadProgress("Circuit data \(i+1) downloaded")
            
            let archivePath = fileUrl.path()
            
            // to drop .tmp file extension
            var unarchiveDest = String(archivePath.dropLast(4))
            unarchiveDest += "\(UUID().uuidString)"
            
            downloadProgress("Unarchiving circuit data \(i + 1)")
            
            SSZipArchive.unzipFile(atPath: archivePath, toDestination: unarchiveDest)
            
            downloadProgress("Circuit data \(i + 1) unarchived")
            
            let fm = FileManager.default
            let unarchiveDir = try fm.contentsOfDirectory(atPath: unarchiveDest).first ?? ""
            let trueUnarchiveDir = "\(unarchiveDest)/\(unarchiveDir)"
            let metadataJsonPath = "\(trueUnarchiveDir)/metadata.json"
            let circuitDatPath = "\(trueUnarchiveDir)/circuit.dat"
            let circuitZkeyPath = "\(trueUnarchiveDir)/circuit.zkey"
            
            downloadProgress("Circuit data \(i + 1) validating")
            
            guard
                let metadataJson = fm.contents(atPath: metadataJsonPath),
                let circuitDat = fm.contents(atPath: circuitDatPath),
                let circuitZkey = fm.contents(atPath: circuitZkeyPath)
            else {
                throw "failed to open some files"
            }
            
            downloadProgress("Saving circuit data \(i + 1)")

            let metadata = try JSONDecoder().decode(RegisterIdentityCircuitMetadata.self, from: metadataJson)
            
            let saveDirectory = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0].appending(path: "circuitsData", directoryHint: .isDirectory)
            
            try fm.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
            
            let circuitDatSavePath = saveDirectory.appending(path: "\(metadata.name).dat")
            let circuitZkeySavePath = saveDirectory.appending(path: "\(metadata.name).zkey")
            
            try circuitDat.write(to: circuitDatSavePath, options: [.atomic])
            try circuitZkey.write(to: circuitZkeySavePath, options: [.atomic])
            
            downloadProgress("Circuit data \(i+1) saved")
            
            downloadProgress("Saving circuit metadata \(i + 1)")
            
            let metadataEntry = RegisterIdentityCircuitMetadataEntry(
                downloadedFrom: url.path(),
                circuitDatPath: circuitDatSavePath,
                circuitZkeyPath: circuitZkeySavePath
            )
            
            registerIdentityMetadataStorageMap[metadata.data.signedAttributesSize] = metadataEntry
            
            let registerIdentityMetadataStorageMapData = try JSONEncoder().encode(registerIdentityMetadataStorageMap)
            
            AppUserDefaults.shared.registerCircuitMetadata = registerIdentityMetadataStorageMapData
            
            downloadProgress("Circuit metadata \(i+1) saved")
        }
        
        downloadProgress("Circuit data downloading finished")
        
        onFinish()
    }
    
    func getRegisterIdentityCircuitData(_ encapsulatedContentSize: Int) throws -> RegisterIdentityCircuitData? {
        let registerIdentityMetadataStorageMapData = AppUserDefaults.shared.registerCircuitMetadata
        
        let registerIdentityMetadataStorageMap = try JSONDecoder().decode([Int: RegisterIdentityCircuitMetadataEntry].self, from: registerIdentityMetadataStorageMapData)
        
        guard let entry = registerIdentityMetadataStorageMap[encapsulatedContentSize] else { return nil }
        
        let circuitDat = try Data(contentsOf: entry.circuitDatPath)
        let circuitZkey = try Data(contentsOf: entry.circuitZkeyPath)
        
        return RegisterIdentityCircuitData(
            circutDat: circuitDat,
            circuitZkey: circuitZkey
        )
    }
}

struct RegisterIdentityCircuitMetadata: Codable {
    let name: String
    let data: RegisterIdentityCircuitMetadataData
}

struct RegisterIdentityCircuitMetadataData: Codable {
    let signedAttributesSize: Int
}

public struct RegisterIdentityCircuitMetadataEntry: Codable {
    let downloadedFrom: String
    let circuitDatPath: URL
    let circuitZkeyPath: URL
}

struct RegisterIdentityCircuitData {
    let circutDat: Data
    let circuitZkey: Data
}
