import SwiftUI

struct PassportProofView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject var mrzViewModel: MRZViewModel
    @EnvironmentObject var passportViewModel: PassportViewModel
    
    @State private var isRegistrationError: Bool = false
    
    let onFinish: (ZkProof) -> Void
    let onClose: () -> Void

    private func register() async {
        do {            
            let zkProof = try await passportViewModel.register()
            if passportViewModel.processingStatus != .success { return }

            try await Task.sleep(nanoseconds: NSEC_PER_SEC)

            onFinish(zkProof)
        } catch {
            if passportViewModel.isUserRegistered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onClose()
                }
            }
            
            self.isRegistrationError = true
            
            LoggerUtil.passport.error("error while registering passport: \(error.localizedDescription)")
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 40) {
                GeneralStatusView(status: passportViewModel.processingStatus)
                VStack(spacing: 16) {
                    ForEach(PassportProofState.allCases, id: \.self) { item in
                        ProcessingItemView(
                            item: item,
                            status: getItemStatus(item)
                        )
                    }
                }
                .padding(20)
                .background(.backgroundOpacity, in: RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 20)
            Spacer()
            footerView
        }
        .padding(.top, 80)
        .task { await register() }
        .onChange(of: passportViewModel.proofState) { _ in
            FeedbackGenerator.shared.impact(.light)
        }
        .onChange(of: passportViewModel.processingStatus) { val in
            FeedbackGenerator.shared.notify(val == .success ? .success : .error)
        }
        .onChange(of: passportViewModel.isAirdropClaimed) { isAirdropClaimed in
            self.walletManager.isClaimed = isAirdropClaimed
        }
        .sheet(isPresented: $passportViewModel.isUserRevoking) {
            RevocationNFCScan()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $isRegistrationError) {
            SendPassportView()
        }
        .background(.backgroundPrimary)
    }

    private func getItemStatus(_ item: PassportProofState) -> ProcessingStatus {
        let isSuccess = passportViewModel.processingStatus == .success ||
            passportViewModel.proofState.rawValue > item.rawValue
        if isSuccess { return .success }

        return passportViewModel.processingStatus == .failure
            ? .failure
            : .processing
    }

    private var footerView: some View {
        VStack(spacing: 16) {
            HorizontalDivider()
            AppButton(text: "Close", action: onClose)
                .disabled(passportViewModel.processingStatus == .processing)
                .controlSize(.large)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .opacity(passportViewModel.processingStatus == .failure ? 1 : 0)
    }
}

private struct ProcessingItemView: View {
    let item: PassportProofState
    let status: ProcessingStatus

    var body: some View {
        HStack(spacing: 4) {
            Text(item.title)
                .body3()
                .foregroundStyle(.textPrimary)
            Spacer()
            ProcessingChipView(status: status)
        }
    }
}

private struct GeneralStatusView: View {
    let status: ProcessingStatus

    private var title: LocalizedStringResource {
        switch status {
        case .processing: "Please Wait..."
        case .success: "All Done!"
        case .failure: "Error"
        }
    }

    private var text: LocalizedStringResource {
        switch status {
        case .processing: "Creating an incognito profile"
        case .success: "Your passport proof is ready"
        case .failure: "Please try again later"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                ZStack {
                    if status == .processing {
                        CirclesLoader()
                    } else {
                        Image(status.icon ?? Icons.dotsThreeOutline)
                            .square(24)
                            .foregroundStyle(status.foregroundColor)
                    }
                }
                .animation(.easeInOut, value: status)
            }
            .frame(width: 80, height: 80)
            .background(status.backgroundColor)
            .clipShape(Circle())
            VStack {
                Text(title)
                    .h6()
                    .foregroundStyle(.textPrimary)
                Text(text)
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

private struct RevocationNFCScan: View {
    @EnvironmentObject var mrzViewModel: MRZViewModel
    @EnvironmentObject var passportViewModel: PassportViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Spacer()
                Image(Icons.swap)
                    .square(80)
                    .foregroundStyle(.textPrimary)
                Text("Please scan your NFC card")
                    .h6()
                    .foregroundStyle(.textPrimary)
                Text("This is required to revoke your passport")
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
                Spacer()
                AppButton(text: "Revoke with NFC") {
                    NFCScanner.scanPassport(
                        mrzViewModel.mrzKey,
                        passportViewModel.revocationChallenge,
                        onCompletion: { result in
                            switch result {
                            case .success(let passport):
                                passportViewModel.revocationPassportPublisher.send(passport)
                                passportViewModel.isUserRevoking = false
                            case .failure(let error):
                                LoggerUtil.passport.error("failed to read passport data: \(error.localizedDescription)")
                                
                                passportViewModel.revocationPassportPublisher.send(completion: .failure(error))
                                
                                passportViewModel.isUserRevoking = false
                            }
                        }
                    )
                }
                .controlSize(.large)
            }
            .padding(20)
            .background(.backgroundOpacity, in: RoundedRectangle(cornerRadius: 24))
        }
    }
}

private struct SendPassportView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var passportViewModel: PassportViewModel
    
    @State private var isSending = false
    
    var body: some View {
        ZStack {
            if !isSending {
                VStack(spacing: 16) {
                    Spacer()
                    Image(Icons.share)
                        .square(80)
                        .foregroundStyle(.textPrimary)
                    Text("Unexpected error")
                        .h6()
                        .foregroundStyle(.textPrimary)
                    Text("We try to support many different passports, but they consist of many different protocols. You can send us your passport and we will try to add it in the future.")
                        .body3()
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                    Text("WARNING: All your passport data will be sent")
                        .body4()
                        .foregroundStyle(.red)
                    Spacer()
                    AppButton(text: "Send passport") {
                        isSending = true
                    }
                    .controlSize(.large)
                }
                .padding(20)
                .background(.backgroundOpacity, in: RoundedRectangle(cornerRadius: 24))
            } else {
                MailView(
                    subject: "Passport from: \(UIDevice.modelName)",
                    attachment: (try? passportViewModel.passport?.serialize()) ?? Data(),
                    fileName: "passport.json",
                    isShowing: $isSending,
                    result: .constant(nil)
                )
            }
        }
        .onChange(of: isSending) { isSending in
            if !isSending {
                dismiss()
            }
        }
    }
}

#Preview {
    @StateObject var userManager = UserManager.shared

    return PassportProofView(onFinish: { _ in }, onClose: {})
        .environmentObject(WalletManager())
        .environmentObject(PassportViewModel())
        .environmentObject(MRZViewModel())
        .environmentObject(UserManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
