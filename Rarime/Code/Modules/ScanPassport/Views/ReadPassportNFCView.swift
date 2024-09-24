import NFCPassportReader
import SwiftUI

struct ReadPassportNFCView: View {
    @EnvironmentObject private var passportViewModel: PassportViewModel
    @EnvironmentObject private var userManager: UserManager

    let onNext: (_ passport: Passport) -> Void
    let onBack: () -> Void
    let onResponseError: () -> Void
    let onClose: () -> Void
    
    @State private var useExtendedMode = false

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
            AppButton(text: "Scan", action: scanPassport)
            .controlSize(.large)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(.backgroundPure)
        }
    }
    
    func scanPassport() {
        NFCScanner.scanPassport(
            passportViewModel.mrzKey ?? "",
            userManager.userChallenge,
            useExtendedMode,
            onCompletion: { result in
                switch result {
                case .success(let passport):
                    self.onNext(passport)
                case .failure(let error):
                    LoggerUtil.passport.error("failed to read passport data: \(error.localizedDescription, privacy: .public)")
                    switch error {
                    case NFCPassportReaderError.Unknown(_):
                        if useExtendedMode {
                            onBack()
                            
                            return
                        }
                        
                        useExtendedMode = true
                        
                        AlertManager.shared.emitError(.unknown("A scanning error occurred. Attempting to use extended mode. Please try again."))
                        
                        scanPassport()
                    case NFCPassportReaderError.ResponseError(let reason, _, _)
                        where reason == "Referenced data not found":
                        onResponseError()
                    default:
                        onBack()
                    }
                }
            }
        )
    }
}

#Preview {
    let userManager = UserManager.shared

    return ReadPassportNFCView(
        onNext: { _ in },
        onBack: {},
        onResponseError: {},
        onClose: {}
    )
    .environmentObject(userManager)
    .environmentObject(PassportViewModel())
    .onAppear {
        _ = try? userManager.createNewUser()
    }
}
