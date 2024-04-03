import QKMRZScanner
import SwiftUI

class MRZScannerController: ObservableObject, QKMRZScannerViewDelegate {
    @Published var isScanning = false
    var scanResults: QKMRZScanner.QKMRZScanResult? = nil
    
    var onScanned: () -> Void = {}
    var mrzKey = ""
    
    func mrzScannerView(_ mrzScannerView: QKMRZScanner.QKMRZScannerView, didFind scanResult: QKMRZScanner.QKMRZScanResult) {
        let dateOfBirth = scanResult.birthdate ?? Date(timeIntervalSince1970: 0)
        let dateOfExpiry = scanResult.expiryDate ?? Date(timeIntervalSince1970: 0)
        
        let mrzDateFormatter = DateFormatter()
        mrzDateFormatter.timeZone = .gmt
        mrzDateFormatter.dateFormat = "yyMMdd"
        
        mrzKey = PassportUtils.getMRZKey(
            passportNumber: scanResult.documentNumber,
            dateOfBirth: mrzDateFormatter.string(from: dateOfBirth),
            dateOfExpiry: mrzDateFormatter.string(from: dateOfExpiry)
        )
        
        scanResults = scanResult
        
        stopScanning()
        onScanned()
    }
    
    func setOnScanned(newOnScanned: @escaping () -> Void) {
        onScanned = newOnScanned
    }
    
    func startScanning() {
        isScanning = true
    }
    
    func stopScanning() {
        isScanning = false
    }
}
