import Alamofire
import SwiftUI

private enum ScanPassportState {
    case importJson
    case scanMRZ
    case readNFC
    case chipError
    case waitlistPassport
}

struct ScanPassportView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var passportViewModel: PassportViewModel

    let onClose: () -> Void

    @State private var state: ScanPassportState = .scanMRZ
    @State private var isTutorialPresented = false
    @State private var isTutorialShown = AppUserDefaults.shared.isScanTutorialDisplayed

    var body: some View {
        switch state {
        case .importJson:
            ImportFileView(
                onFinish: { passport in
                    passportViewModel.setPassport(passport)
                    onClose()
                    Task { await register(passport) }
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
            .padding(.bottom, 16)
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .readNFC:
            ReadPassportNFCView(
                onNext: { passport in
                    passportViewModel.setPassport(passport)
                    onClose()
                    Task { await register(passport) }
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
        case .waitlistPassport:
            WaitlistPassportView(
                onNext: {
                    userManager.user?.status = .passportScanned
                    passportManager.setPassport(passportViewModel.passport!)
                    onClose()
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
    
    private func register(_ passport: Passport) async {
        do {
            passportManager.setPassport(passport)
            
            let zkProof = try await passportViewModel.register()

            if passportViewModel.processingStatus != .success { return }

            userManager.registerZkProof = zkProof
            userManager.user?.status = .passportScanned

            LoggerUtil.common.info("Passport read successfully: \(passport.fullName, privacy: .public)")
        } catch {
            LoggerUtil.common.error("error while registering passport: \(error.localizedDescription, privacy: .public)")
            
            if passportViewModel.isUserRegistered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onClose()
                }
            }

            if let afError = error as? AFError {
                if case .sessionTaskFailed = afError {
                    LoggerUtil.common.error("Network connection lost")

                    AlertManager.shared.emitError(.connectionUnstable)

                    onClose()
                    
                    passportViewModel.processingStatus = .failure

                    return
                }
            } else if let error = error as? Errors {
                AlertManager.shared.emitError(error)

                onClose()
                
                passportViewModel.processingStatus = .failure

                return
            }
            
            withAnimation { state = .waitlistPassport }
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    return ScanPassportView(onClose: {})
    .environmentObject(WalletManager())
    .environmentObject(userManager)
    .environmentObject(PassportManager())
    .environmentObject(PassportViewModel())
    .onAppear {
        _ = try? userManager.createNewUser()
    }
}
