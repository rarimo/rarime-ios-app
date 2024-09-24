import SwiftUI

struct ScanPassportMRZView: View {
    let onNext: (String) -> Void
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
                MRZScanView(onMrzKey: onNext)
                Image(Images.passportFrame)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
            }
            .frame(maxWidth: .infinity)
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
                    LoggerUtil.passport.info("MRZ filled manually")
                    
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
}
