import QKMRZScanner
import SwiftUI

struct MRZScannerView: UIViewRepresentable {
    @ObservedObject var mrzScannerController: MRZScannerController
    
    init(mrzScannerController: MRZScannerController) {
        self.mrzScannerController = mrzScannerController
    }
    
    typealias UIViewType = QKMRZScannerView
    
    func makeUIView(context: Context) -> QKMRZScanner.QKMRZScannerView {
        QKMRZScannerView()
    }
    
    func updateUIView(_ uiView: QKMRZScanner.QKMRZScannerView, context: Context) {
        if mrzScannerController.isScanning {
            uiView.delegate = mrzScannerController
            uiView.startScanning()
            return
        }
        
        uiView.stopScanning()
    }
}

#Preview {
    MRZScannerView(mrzScannerController: MRZScannerController())
}
