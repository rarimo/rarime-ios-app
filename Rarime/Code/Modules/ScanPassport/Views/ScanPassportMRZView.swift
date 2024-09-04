import SwiftUI

struct ScanPassportMRZView: View {
    @EnvironmentObject var mrzViewModel: MRZViewModel
    let onNext: () -> Void
    let onClose: () -> Void

    @State private var isManualMrzSheetPresented = false

    var body: some View {
        ScanPassportLayoutView(
            step: 1,
            title: "Scan your Passport",
            text: "Data never leaves this device",
            onClose: onClose
        ) {
            ZStack {
                CameraPermissionView(delay: 0.5, onCancel: onClose) {
                    MRZScannerView().environmentObject(mrzViewModel)
                    LottieView(animation: Animations.passport, contentMode: .scaleToFill)
                        .frame(width: 350, height: 256)
                        .padding(.bottom, 2)
                }
            }
            .frame(height: 300)
            Text("Move your passport page inside the border")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .frame(width: 250)
            Spacer()
            PassportScanTutorialButton()
                .padding(.horizontal, 20)
            AppButton(
                variant: .tertiary,
                text: "Fill Manually",
                leftIcon: Icons.pencilSimpleLine,
                action: { isManualMrzSheetPresented = true }
            )
            .controlSize(.large)
            .padding(.horizontal, 20)
            .dynamicSheet(isPresented: $isManualMrzSheetPresented, title: "Fill Manually") {
                MrzFormView(onSubmitted: { mrzKey in
                    mrzViewModel.setMrzKey(mrzKey)
                    LoggerUtil.passport.info("MRZ filled manually")
                    onNext()
                })
            }
        }
        .onAppear {
            mrzViewModel.setOnScanned {
                LoggerUtil.passport.info("MRZ scanned")

                onNext()
            }
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
