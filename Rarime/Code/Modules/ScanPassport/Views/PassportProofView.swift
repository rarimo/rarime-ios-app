import SwiftUI

struct PassportProofView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel

    let onFinish: (ZkProof) -> Void
    let onClose: () -> Void

    private func generateProof() async {
        do {
            let zkProof = try await passportViewModel.generateProof()
            if passportViewModel.processingStatus != .success { return }

            try await Task.sleep(nanoseconds: NSEC_PER_SEC)

            onFinish(zkProof)
        } catch {
            LoggerUtil.passport.error("Error while waiting for success state: \(error)")
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
                .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 20)
            Spacer()
            footerView
        }
        .padding(.top, 80)
        .task { await generateProof() }
        .onChange(of: passportViewModel.proofState) { _ in
            FeedbackGenerator.shared.impact(.light)
        }
        .onChange(of: passportViewModel.processingStatus) { val in
            FeedbackGenerator.shared.notify(val == .success ?.success : .error)
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

#Preview {
    @StateObject var userManager = UserManager.shared

    return PassportProofView(onFinish: { _ in }, onClose: {})
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
