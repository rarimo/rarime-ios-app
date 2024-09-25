import SwiftUI

struct PassportProofView: View {
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject var passportViewModel: PassportViewModel

    let onFinish: (ZkProof) -> Void
    let onClose: () -> Void
    let onError: (Error) -> Void

    private func register() async {
        do {
            let zkProof = try await passportViewModel.register { progress in
                passportViewModel.processingStatus = .downloading(progress)
            }

            if passportViewModel.processingStatus != .success { return }

            try await Task.sleep(nanoseconds: NSEC_PER_SEC)

            onFinish(zkProof)
        } catch {
            if passportViewModel.isUserRegistered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onClose()
                }
            }

            LoggerUtil.passport.error("error while registering passport: \(error.localizedDescription, privacy: .public)")
            onError(error)
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
        .onChange(of: passportViewModel.processingStatus) { status in
            switch status {
            case .success: FeedbackGenerator.shared.notify(.success)
            case .failure: FeedbackGenerator.shared.notify(.error)
            default: break
            }
        }
        .onChange(of: passportViewModel.isAirdropClaimed) { isAirdropClaimed in
            self.walletManager.isClaimed = isAirdropClaimed
        }
        .sheet(isPresented: $passportViewModel.isUserRevoking) {
            RevocationNFCScan()
                .interactiveDismissDisabled()
        }
        .background(.backgroundPrimary)
    }

    private func getItemStatus(_ item: PassportProofState) -> ProcessingStatus {
        let isSuccess = passportViewModel.processingStatus == .success ||
            passportViewModel.proofState.rawValue > item.rawValue
        if isSuccess { return .success }

        if item == .downloadingData {
            if case .downloading(let progress) = passportViewModel.processingStatus {
                return .downloading(progress)
            }
        }

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
        case .downloading(_), .processing: "Please Wait..."
        case .success: "All Done!"
        case .failure: "Error"
        }
    }

    private var text: LocalizedStringResource {
        switch status {
        case .downloading(_), .processing: "Creating an incognito profile"
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
    @EnvironmentObject var passportViewModel: PassportViewModel

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(Icons.warning)
                .iconLarge()
                .frame(width: 72, height: 72)
                .background(.warningLighter, in: Circle())
                .foregroundStyle(.warningMain)
            Text("Passport is already registered")
                .h6()
                .foregroundStyle(.textPrimary)
            Text("Please, scan your passport one more time to revoke your previous registration")
                .body3()
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            AppButton(text: "Scan passport") {
                NFCScanner.scanPassport(
                    passportViewModel.mrzKey ?? "",
                    passportViewModel.revocationChallenge,
                    false,
                    onCompletion: { result in
                        switch result {
                        case .success(let passport):
                            passportViewModel.revocationPassportPublisher.send(passport)
                            passportViewModel.isUserRevoking = false
                        case .failure(let error):
                            LoggerUtil.passport.error("failed to read passport data: \(error.localizedDescription, privacy: .public)")

                            passportViewModel.revocationPassportPublisher.send(completion: .failure(error))

                            passportViewModel.isUserRevoking = false
                        }
                    }
                )
            }
            .controlSize(.large)
        }
        .padding(20)
    }
}

#Preview {
    @StateObject var userManager = UserManager.shared

    return PassportProofView(onFinish: { _ in }, onClose: {}, onError: { _ in })
        .environmentObject(WalletManager())
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
        .environmentObject(DecentralizedAuthManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
