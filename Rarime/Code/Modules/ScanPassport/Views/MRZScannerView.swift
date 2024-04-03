import QKMRZScanner
import SwiftUI

struct MRZScannerView: UIViewRepresentable {
    @EnvironmentObject var mrzViewModel: MRZViewModel
    
    typealias UIViewType = QKMRZScannerView
    
    func makeUIView(context: Context) -> QKMRZScanner.QKMRZScannerView {
        QKMRZScannerView()
    }
    
    func updateUIView(_ uiView: QKMRZScanner.QKMRZScannerView, context: Context) {
        if mrzViewModel.isScanning {
            uiView.delegate = mrzViewModel
            uiView.startScanning()
            return
        }
        
        uiView.stopScanning()
    }
}

#Preview {
    MRZScannerView().environmentObject(MRZViewModel())
}
