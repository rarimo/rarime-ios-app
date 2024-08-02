import QKMRZScanner
import SwiftUI

class MRZViewModel: ObservableObject, QKMRZScannerViewDelegate {
    @Published var isScanning = false
    var mrzKey = ""
    var onScanned: () -> Void = {}
    
    func mrzScannerView(_ mrzScannerView: QKMRZScanner.QKMRZScannerView, didFind scanResult: QKMRZScanner.QKMRZScanResult) {
        let dateOfBirth = scanResult.birthdate ?? Date(timeIntervalSince1970: 0)
        let dateOfExpiry = scanResult.expiryDate ?? Date(timeIntervalSince1970: 0)
        
        mrzKey = PassportUtils.getMRZKey(
            passportNumber: scanResult.documentNumber,
            dateOfBirth: DateUtil.passportDateFormatter.string(from: dateOfBirth),
            dateOfExpiry: DateUtil.passportDateFormatter.string(from: dateOfExpiry)
        )
        
        stopScanning()
        onScanned()
    }
    
    func setMrzKey(_ mrzKey: String) {
        self.mrzKey = mrzKey
    }
    
    func setOnScanned(onScanned: @escaping () -> Void) {
        self.onScanned = onScanned
    }
    
    func startScanning() {
        isScanning = true
    }
    
    func stopScanning() {
        isScanning = false
    }
}
