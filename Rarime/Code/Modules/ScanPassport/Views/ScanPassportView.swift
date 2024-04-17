import SwiftUI

private enum ScanPassportState {
    case scanMRZ, readNFC, selectData, generateProof, claimTokens
}

struct ScanPassportView: View {
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
                onFinish: {
                    if passportViewModel.isEligibleForReward {
                        withAnimation { state = .claimTokens }
                    } else {
                        onComplete(passportViewModel.passport!, false)
                    }
                },
                onClose: onClose
            )
            .environmentObject(passportViewModel)
            .transition(.backslide)
        case .claimTokens:
            ClaimTokensView(onFinish: { onComplete(passportViewModel.passport!, true) })
                .environmentObject(passportViewModel)
                .transition(.backslide)
        }
    }
}

#Preview {
    ScanPassportView(
        onComplete: { _, _ in },
        onClose: {}
    )
}
