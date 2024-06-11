import SwiftUI

private enum ScanPassportState {
    case scanMRZ
    case readNFC
    case selectData
    case unsupportedCountry
    case generateProof
    case waitlistPassport
    case claimTokens
    case reserveTokens
}

struct ScanPassportView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager

    let isAirdropFlow: Bool
    let onComplete: (_ passport: Passport, _ isClaimed: Bool) -> Void
    let onClose: () -> Void

    @State private var state: ScanPassportState = .scanMRZ

    @StateObject private var passportViewModel = PassportViewModel()
    @StateObject private var mrzViewModel = MRZViewModel()

    var body: some View {
        switch state {
        case .scanMRZ:
            ScanPassportMRZView(
                onNext: { withAnimation { state = .readNFC } },
                onClose: onClose
            )
            .environmentObject(mrzViewModel)
            .transition(.backslide)
        case .readNFC:
            ReadPassportNFCView(
                onNext: { passport in
                    passportViewModel.setPassport(passport)
                    withAnimation { state = .selectData }

                    LoggerUtil.passport.info("Passport read successfully: \(passport.fullName, privacy: .public)")
                },
                onBack: { withAnimation { state = .scanMRZ } },
                onClose: onClose
            )
            .environmentObject(mrzViewModel)
            .transition(.backslide)
        case .selectData:
            SelectPassportDataView(
                isAirdropFlow: isAirdropFlow,
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
                    if !isAirdropFlow {
                        withAnimation { state = .reserveTokens }
                        return
                    }

                    if
                        !passportViewModel.isUserRevoked,
                        passportViewModel.isEligibleForReward,
                        !passportViewModel.isAirdropClaimed,
                        !walletManager.isClaimed
                    {
                        LoggerUtil.passport.info("User is eligible for reward")
                        withAnimation { state = .claimTokens }
                    } else {
                        onComplete(passportViewModel.passport!, false)
                    }
                },
                onClose: onClose,
                onError: { withAnimation { state = .waitlistPassport } }
            )
            .environmentObject(mrzViewModel)
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .waitlistPassport:
            WaitlistPassportView(
                onNext: { onComplete(passportViewModel.passport!, false) },
                onCancel: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .claimTokens:
            ClaimTokensView(
                showTerms: false,
                passport: passportViewModel.passport,
                onFinish: { isClaimed in
                    onComplete(passportViewModel.passport!, isClaimed)
                },
                onClose: { onComplete(passportViewModel.passport!, false) }
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .reserveTokens:
            ReserveTokensView(
                showTerms: false,
                passport: passportViewModel.passport,
                onFinish: { isReserved in
                    onComplete(passportViewModel.passport!, isReserved)
                },
                onClose: { onComplete(passportViewModel.passport!, false) }
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    return ScanPassportView(
        isAirdropFlow: false,
        onComplete: { _, _ in },
        onClose: {}
    )
    .environmentObject(WalletManager())
    .environmentObject(userManager)
    .environmentObject(PassportManager())
    .onAppear {
        _ = try? userManager.createNewUser()
    }
}
