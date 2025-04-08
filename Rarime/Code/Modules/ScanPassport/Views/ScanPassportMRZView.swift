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
                MRZScanView(onMrzKey: onNext)
                Image(Images.passportFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 228)
            }
            .frame(maxWidth: .infinity)
            Text("Scan your passport’s first page inside the border")
                .overline2()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .frame(width: 250)
            Spacer()
            AppButton(
                variant: .quartenary,
                text: "Fill Manually",
                action: { isManualMrzSheetPresented = true }
            )
            .controlSize(.large)
            .padding(.horizontal, 20)
            .dynamicSheet(isPresented: $isManualMrzSheetPresented, title: "Fill Manually") {
                MrzFormView(onSubmitted: { mrzKey in
                    LoggerUtil.common.info("MRZ filled manually")
                    onNext(mrzKey)
                })
            }
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
