import SwiftUI

struct ScanPassportMRZView: View {
    let onNext: (String) -> Void
    let onClose: () -> Void

    @State private var isManualMrzSheetPresented = false

    var body: some View {
        ScanPassportLayoutView(
            currentStep: 0,
            title: "Scan MRZ",
            onClose: onClose
        ) {
            ZStack {
                CameraPermissionView(onCancel: onClose) {
                    MRZScanView(onMrzKey: onNext)
                }
                Image(.passportFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 228)
            }
            .frame(maxWidth: .infinity)
            Text("Scan your passport’s first page inside the border")
                .body4()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .frame(width: 250)
            Spacer()
            VStack(spacing: 8) {
                PassportScanTutorialButton()
                AppButton(
                    variant: .quartenary,
                    text: "Fill Manually",
                    action: { isManualMrzSheetPresented = true }
                )
                .controlSize(.large)
                .dynamicSheet(isPresented: $isManualMrzSheetPresented, title: "Fill Manually") {
                    MrzFormView(onSubmitted: { mrzKey in
                        LoggerUtil.common.info("MRZ filled manually")
                        onNext(mrzKey)
                    })
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ScanPassportMRZView(
        onNext: { _ in },
        onClose: {}
    )
    .environmentObject(PassportViewModel())
}
