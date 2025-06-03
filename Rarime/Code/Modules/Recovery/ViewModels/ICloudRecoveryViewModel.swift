import CloudKit

class ICloudRecoveryViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var isProcessing = false

    @Published var isICloudAvailable = false
    @Published var cloudRecord: CKRecord? = nil

    var cloudKey: Data? {
        guard let cloudRecord = cloudRecord else { return nil }
        return cloudRecord.value(forKey: User.userCloudPrivateKeyKey) as? Data
    }

    var isKeysEqual: Bool {
        guard let user = UserManager.shared.user else { return false }
        return user.secretKey.hex == cloudKey?.hex
    }

    func loadBackupStatus() async {
        defer { isLoading = false }
        do {
            isICloudAvailable = try await CloudStorage.shared.isICloudAvailable()
            if !isICloudAvailable { return }

            let query = CKQuery(recordType: User.userCloudRecordType, predicate: NSPredicate(value: true))
            let records = try await CloudStorage.shared.fetchRecords(query)

            cloudRecord = records.last
        } catch {
            LoggerUtil.common.error("Failed to load backup status: \(error, privacy: .public)")
            AlertManager.shared.emitError(String(localized: "Failed to load backup status"))
        }
    }

    func backUpUserSecretKey() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let record = try await UserManager.shared.user?.saveUserPrivateKeyToCloud()
            if record == nil {
                throw Errors.unknown("Backup already exists")
            }

            cloudRecord = record
        } catch {
            LoggerUtil.common.error("back up error: \(error, privacy: .public)")
            AlertManager.shared.emitError(String(localized: "Failed to back up, try again later"))
        }
    }

    func deleteBackup() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await CloudStorage.shared.deleteRecord(cloudRecord!.recordID)
            await loadBackupStatus()
        } catch {
            LoggerUtil.common.error("Failed to delete backup: \(error, privacy: .public)")
            AlertManager.shared.emitError(String(localized: "Failed to delete backup"))
        }
    }
}
