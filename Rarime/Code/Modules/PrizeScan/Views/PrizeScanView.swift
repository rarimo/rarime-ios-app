import SwiftUI

struct PrizeScanView: View {
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var viewModel: PrizeScanViewModel

    let onClose: () -> Void
    var animation: Namespace.ID

    @State private var isScanSheetPresented = false
    @State private var isBonusScanSheetPresented = false

    private var prizeScanUser: PrizeScanUser {
        viewModel.user ?? PrizeScanUser.empty()
    }

    private var totalAttemptsLeft: Int {
        prizeScanUser.attemptsLeft + prizeScanUser.extraAttemptsLeft
    }

    private var hasAttempts: Bool {
        totalAttemptsLeft > 0
    }

    private var canGetBonusScans: Bool {
        !prizeScanUser.socialShare || prizeScanUser.referralsCount < prizeScanUser.referralsLimit
    }

    private var tip: String {
        prizeScanUser.celebrity?.hint ?? ""
    }

    var invitationLink: String {
        ConfigManager.shared.api.referralURL.appendingPathComponent(prizeScanUser.referralCode).absoluteString
    }

    private var imageToShare: Data {
        // TODO: use different image for sharing
        UIImage(named: "HiddenPrizeBg")!.pngData()!
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PullToCloseWrapperView(action: onClose) {
                ZStack(alignment: .bottom) {
                    GlassBottomSheet(
                        minHeight: 470,
                        maxHeight: 730,
                        maxBlur: 100,
                        background: {
                            Image(.hiddenPrizeBg)
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                                .ignoresSafeArea()
                        }
                    ) {
                        mainSheetContent
                    }
                }
            }
            Button(action: onClose) {
                Image(.closeFill)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(10)
                    .background(.bgComponentPrimary, in: Circle())
            }
            .padding([.top, .trailing], 20)
        }
        .sheet(isPresented: $isScanSheetPresented) {
            PrizeScanCameraView(onClose: { isScanSheetPresented = false })
                .interactiveDismissDisabled()
        }
        .background(.invertedLight)
    }

    var mainSheetContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Hidden keys")
                    .h1()
                    .foregroundStyle(.invertedDark)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.title,
                        in: animation,
                        properties: .position
                    )
                Text("Find a face")
                    .additional1()
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Gradients.purpleText)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.subtitle,
                        in: animation,
                        properties: .position
                    )
                Text("Somewhere out on the open web, one famous face carries a key sealed inside its ZK-vector.  Test any image you find, and the first player to prove the match claims the prize. Ready to hunt?")
                    .body4()
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
            }
            if !tip.isEmpty {
                scanTip
            }
            HorizontalDivider()
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available")
                        .subtitle6()
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: 2) {
                        Text(verbatim: "\(totalAttemptsLeft)")
                            .h4()
                            .foregroundStyle(Gradients.purpleText)
                        Text("/\(prizeScanUser.totalAttemptsCount) scans")
                            .body4()
                            .foregroundStyle(.textSecondary)
                    }
                }
                Spacer()
                scanActions
            }
        }
        .padding([.top, .horizontal], 20)
        // TODO: fix bottom padding
        .padding(.bottom, 420)
        .background(.invertedLight, in: RoundedRectangle(cornerRadius: 16))
    }

    private var scanTip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(.bulb).iconSmall()
                Text("Tip:").subtitle7()
            }
            .foregroundStyle(Gradients.purpleText)
            Text(verbatim: tip)
                .body4()
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Gradients.purpleText.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }

    private var scanActions: some View {
        ZStack {
            if hasAttempts || !canGetBonusScans {
                AppButton(
                    variant: .primary,
                    // TODO: timer
                    text: hasAttempts ? "Scan" : "23:59:59",
                    leftIcon: hasAttempts ? Icons.userFocus : Icons.lock,
                    width: 160,
                    action: {
                        isScanSheetPresented = true
                    }
                )
                .controlSize(.large)
                .disabled(!hasAttempts)
            } else {
                Button(action: { isBonusScanSheetPresented = true }) {
                    HStack(spacing: 12) {
                        Image(.flashlightFill)
                            .iconMedium()
                        Text("Bonus scan")
                            .buttonLarge()
                    }
                    .foregroundStyle(.baseWhite)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 24)
                    .background(Gradients.purpleText, in: RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .dynamicSheet(isPresented: $isBonusScanSheetPresented) {
            bonusScanSheetContent
        }
    }

    private var bonusScanSheetContent: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 0) {
                Image(.flashlightFill)
                    .square(24)
                    .padding(16)
                    .foregroundStyle(Gradients.purpleText)
                    .background(Gradients.purpleText.opacity(0.05), in: Circle())
                Text("Bonus scan")
                    .h3()
                    .foregroundStyle(.textPrimary)
                    .padding(.top, 20)
                Text("Out of daily scans? Earn extra scans for every friend who joins and a one-time by sharing the hunt")
                    .body3()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
            }
            HorizontalDivider()
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Image(.shareLine)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                        .padding(10)
                        .background(.bgComponentPrimary, in: Circle())
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Share on socials")
                            .subtitle5()
                            .foregroundStyle(.textPrimary)
                        Text("+1 scan")
                            .body5()
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ShareLink(
                        item: imageToShare,
                        subject: Text("Hidden Prize Scan"),
                        preview: SharePreview("Hidden Prize Scan", image: Image(uiImage: UIImage(data: imageToShare)!))
                    ) {
                        Text("Share")
                            .buttonMedium()
                            .foregroundStyle(.invertedLight)
                    }
                    .frame(width: 100, height: 32)
                    .background(.textPrimary, in: RoundedRectangle(cornerRadius: 12))
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            await getExtraAttempt()
                        }
                    })
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 16) {
                    Image(.userAddLine)
                        .iconMedium()
                        .foregroundStyle(.textPrimary)
                        .padding(10)
                        .background(.bgComponentPrimary, in: Circle())
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Invite a friend")
                            .subtitle5()
                            .foregroundStyle(.textPrimary)
                        Text("\(prizeScanUser.referralsCount)/\(prizeScanUser.referralsLimit) invited")
                            .body5()
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ShareLink(
                        item: URL(string: invitationLink)!,
                        subject: Text("Invite to Hidden Prize Scan"),
                        message: Text("Join Hidden Prize Scan with my link:\n\n\(invitationLink)")
                    ) {
                        Text("Invite")
                            .buttonMedium()
                            .foregroundStyle(.invertedLight)
                    }
                    .frame(width: 100, height: 32)
                    .background(.textPrimary, in: RoundedRectangle(cornerRadius: 12))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
    }

    private func getExtraAttempt() async {
        do {
            guard let user = userManager.user else { throw "failed to get user" }
            let accessJwt = try await decentralizedAuthManager.getAccessJwt(user)
            try await viewModel.getExtraAttempt(jwt: accessJwt)
        } catch {
            LoggerUtil.common.error("failed to get extra attempt: \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    PrizeScanView(onClose: {}, animation: Namespace().wrappedValue)
        .environmentObject(UserManager())
        .environmentObject(DecentralizedAuthManager())
        .environmentObject(PrizeScanViewModel())
}
