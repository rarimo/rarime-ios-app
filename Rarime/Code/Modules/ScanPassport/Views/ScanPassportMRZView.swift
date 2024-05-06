import SwiftUI

struct ScanPassportMRZView: View {
    @EnvironmentObject var mrzViewModel: MRZViewModel
    let onNext: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScanPassportLayoutView(
            step: 1,
            title: "Scan your Passport",
            text: "Data never leaves this device",
            onClose: onClose
        ) {
            ZStack {
                MRZScannerView().environmentObject(mrzViewModel)
                LottieView(animation: Animations.passport, contentMode: .scaleToFill)
                    .frame(width: 350, height: 256)
                    .padding(.bottom, 2)
            }
            .frame(height: 300)
            Text("Move your passport page inside the border")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
                .frame(width: 250)
            Spacer()
        }
        .onAppear {
            mrzViewModel.setOnScanned { onNext() }
            mrzViewModel.startScanning()
        }
    }
}

#Preview {
    ScanPassportMRZView(
        onNext: {},
        onClose: {}
    )
    .environmentObject(MRZViewModel())
}
