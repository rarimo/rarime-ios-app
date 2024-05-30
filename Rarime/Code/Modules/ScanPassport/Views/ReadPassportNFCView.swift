import SwiftUI

struct ReadPassportNFCView: View {
    @EnvironmentObject private var mrzViewModel: MRZViewModel
    @EnvironmentObject private var userManager: UserManager

    let onNext: (_ passport: Passport) -> Void
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScanPassportLayoutView(
            step: 2,
            title: "NFC Reader",
            text: "Reading Passport data",
            onClose: onClose
        ) {
            LottieView(animation: Animations.scanPassport)
                .frame(width: .infinity, height: 300)
            Text("Place your passport cover to the back of your phone")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
                .frame(width: 250)
            Spacer()
            AppButton(text: "Scan") {
                NFCScanner.scanPassport(
                    mrzViewModel.mrzKey,
                    userManager.userChallenge,
                    onCompletion: { result in
                        switch result {
                        case .success(let passport):
                            self.onNext(passport)
                        case .failure(let error):
                            LoggerUtil.passport.error("failed to read passport data: \(error.localizedDescription)")
                            self.onBack()
                        }
                    }
                )
            }
            .controlSize(.large)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(.backgroundPure)
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    return ReadPassportNFCView(
        onNext: { _ in },
        onBack: {},
        onClose: {}
    )
    .environmentObject(MRZViewModel())
    .environmentObject(userManager)
    .onAppear {
        _ = try? userManager.createNewUser()
    }
}
