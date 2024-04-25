import SwiftUI

private enum ScanPassportState {
    case scanMRZ, readNFC, selectData, generateProof, claimTokens
}

struct ScanPassportView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var circuitDataManager: CircuitDataManager
    
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
                },
                onBack: { withAnimation { state = .scanMRZ } },
                onClose: onClose
            )
            .environmentObject(mrzViewModel)
            .transition(.backslide)
        case .selectData:
            SelectPassportDataView(
                onNext: { withAnimation { state = .generateProof } },
                onClose: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .generateProof:
            PassportProofView(
                onFinish: { registerZKProof in
                    do {
                        try userManager.saveRegisterZkProof(registerZKProof)
                        
                        if passportViewModel.isEligibleForReward, !walletManager.isClaimed {
                            withAnimation { state = .claimTokens }
                        } else {
                            onComplete(passportViewModel.passport!, false)
                        }
                    } catch {
                        LoggerUtil.passport.error("unexpected error: \(error)")
                    }
                },
                onClose: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .claimTokens:
            ClaimTokensView(
                onFinish: { onComplete(passportViewModel.passport!, true) }
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        }
    }
}

#Preview {
    let userManager = UserManager.shared
    
    return ScanPassportView(
        onComplete: { _, _ in },
        onClose: {}
    )
    .environmentObject(WalletManager())
    .environmentObject(userManager)
    .environmentObject(CircuitDataManager.shared)
    .onAppear {
        _ = try? userManager.createNewUser()
    }
}
