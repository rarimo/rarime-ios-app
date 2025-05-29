import AVKit
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
            currentStep: 1,
            title: "NFC Reader",
            onPrevious: onBack,
            onClose: onClose
        ) {
            GeometryReader { geometry in
                VStack(spacing: 24) {
                    LoopVideoPlayer(url: passportViewModel.isUSA ? Videos.readNfcUsa : Videos.readNfc)
                        .aspectRatio(16 / 9, contentMode: .fill)
                        .frame(width: geometry.size.width)
                        .clipped()

                    Spacer()

                    AppButton(text: "Scan", action: scanPassport)
                        .controlSize(.large)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
            }
        }
    }

    private func scanPassport() {
        NFCScanner.scanPassport(
            passportViewModel.mrzKey ?? "",
            userManager.userChallenge,
            useExtendedMode,
            onCompletion: { result in
                switch result {
                case .success(let passport):
                    if passport.isExpired {
                        LoggerUtil.common.info("Passport is expired")
                        AlertManager.shared.emitError(.unknown("Passport is expired"))
                        onClose()
                        return
                    }

                    if !passport.isOver18 {
                        LoggerUtil.common.info("User is underage")
                        AlertManager.shared.emitError(.unknown("You are under 18"))
                        onClose()
                        return
                    }

                    if passport.documentType != DocumentType.passport.rawValue {
                        LoggerUtil.common.info("Document is not ePassport")
                        AlertManager.shared.emitError(.unknown("Document is not ePassport"))
                        onClose()
                        return
                    }

                    self.onNext(passport)
                case .failure(let error):
                    LoggerUtil.common.error("failed to read passport data: \(error.localizedDescription, privacy: .public)")
                    switch error {
                    case NFCPassportReaderError.Unknown:
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
