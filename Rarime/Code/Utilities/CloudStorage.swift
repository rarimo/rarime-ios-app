import Foundation
import CloudKit

class CloudStorage {
    static let shared = CloudStorage()

    let db = CKContainer(identifier: "iCloud.Rarilabs.Rarime").privateCloudDatabase

    func saveRecord(_ record: CKRecord) async throws {
        let _ = try await db.save(record)
    }

    func fetchRecords(_ query: CKQuery) async throws -> [CKRecord] {
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let (results, _) = try await db.records(matching: query)
        
        var records: [CKRecord] = []
        for (_, recordSearchResult) in results {
            switch recordSearchResult {
            case .success(let record):
                records.append(record)
            case .failure(let error):
                throw error
            }
        }

        return records
    }

    func deleteRecord(_ id: CKRecord.ID) async throws {
        let _ = try await db.deleteRecord(withID: id)
    }

    func isICloudAvailable() async throws -> Bool {
        let accountStatus = try await CKContainer(identifier: "iCloud.Rarilabs.Rarime").accountStatus()

        return accountStatus == .available
    }
}
