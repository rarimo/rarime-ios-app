import Alamofire
import SwiftUI

private enum ScanPassportState {
    case importJson
    case scanMRZ
    case readNFC
    case chipError
    case selectData
    case unsupportedCountry
    case generateProof
    case waitlistPassport
}

struct ScanPassportView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager

    let onComplete: (_ passport: Passport) -> Void
    let onClose: () -> Void

    @State private var state: ScanPassportState = .scanMRZ
    @State private var isTutorialPresented = false
    @State private var isTutorialShown = AppUserDefaults.shared.isScanTutorialDisplayed

    @StateObject private var passportViewModel = PassportViewModel()

    var body: some View {
        switch state {
        case .importJson:
            ImportFileView(
                onFinish: { passport in
                    passportViewModel.setPassport(passport)

                    withAnimation { state = .selectData }
                },
                onClose: onClose
            )
            .transition(.backslide)
        case .scanMRZ:
            VStack(spacing: 8) {
                ScanPassportMRZView(
                    onNext: { mrzKey in
                        passportViewModel.setMrzKey(mrzKey)

                        withAnimation { state = .readNFC }
                    },
                    onClose: onClose
                )
                .dynamicSheet(isPresented: $isTutorialPresented, fullScreen: true) {
                    PassportScanTutorialView(onStart: { isTutorialPresented = false })
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentScanTutorialIfNeeded()
                    }
                }

#if DEVELOPMENT
                AppButton(
                    text: "Import JSON",
                    leftIcon: Icons.share1,
                    action: { withAnimation { state = .importJson } }
                )
                .controlSize(.large)
                .padding(.horizontal, 20)
#endif
            }
            .padding(.bottom, 20)
            .background(.backgroundPrimary)
            .transition(.backslide)
        case .readNFC:
            ReadPassportNFCView(
                onNext: { passport in
                    passportViewModel.setPassport(passport)
                    withAnimation { state = .selectData }

                    LoggerUtil.passport.info("Passport read successfully: \(passport.fullName, privacy: .public)")
                },
                onBack: { withAnimation { state = .scanMRZ } },
                onResponseError: { withAnimation { state = .chipError } },
                onClose: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .chipError:
            PassportChipErrorView(onClose: onClose)
                .transition(.backslide)
        case .selectData:
            SelectPassportDataView(
                onNext: {
                    let isSupportedCountry = !UNSUPPORTED_REWARD_COUNTRIES.contains(passportViewModel.passportCountry)
                    withAnimation { state = isSupportedCountry ? .generateProof : .unsupportedCountry }
                },
                onClose: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .unsupportedCountry:
            UnsupportedCountryView(
                onCreate: { withAnimation { state = .generateProof } },
                onCancel: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .generateProof:
            PassportProofView(
                onFinish: { registerZKProof in
                    userManager.registerZkProof = registerZKProof
                    onComplete(passportViewModel.passport!)
                },
                onClose: onClose,
                onError: { error in
                    if let afError = error as? AFError {
                        if case .sessionTaskFailed = afError {
                            LoggerUtil.common.error("Network connection lost")

                            AlertManager.shared.emitError(.connectionUnstable)

                            onClose()

                            return
                        }
                    }

                    withAnimation { state = .waitlistPassport }
                }
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .waitlistPassport:
            WaitlistPassportView(
                onNext: {
                    onComplete(passportViewModel.passport!)
                },
                onCancel: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        }
    }

    private func presentScanTutorialIfNeeded() {
        if !AppUserDefaults.shared.isScanTutorialDisplayed {
            isTutorialPresented = !isTutorialShown
            isTutorialShown = true
            AppUserDefaults.shared.isScanTutorialDisplayed = true
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    return ScanPassportView(
        onComplete: { _ in },
        onClose: {}
    )
    .environmentObject(WalletManager())
    .environmentObject(userManager)
    .environmentObject(PassportManager())
    .onAppear {
        _ = try? userManager.createNewUser()
    }
}
