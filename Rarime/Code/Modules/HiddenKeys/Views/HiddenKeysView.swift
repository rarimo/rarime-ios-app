import SwiftUI

struct HiddenKeysView: View {
    @EnvironmentObject private var viewModel: HiddenKeysViewModel

    var animation: Namespace.ID
    let onClose: () -> Void
    let onViewWallet: () -> Void

    @State private var isScanSheetPresented = false
    @State private var isBonusScanSheetPresented = false

    @State private var isShareSheetPresented = false

    private var hiddenKeysUser: HiddenKeysUser {
        viewModel.user ?? HiddenKeysUser.empty()
    }

    private var totalAttemptsLeft: Int {
        hiddenKeysUser.attemptsLeft + hiddenKeysUser.extraAttemptsLeft
    }

    private var hasAttempts: Bool {
        totalAttemptsLeft > 0
    }

    private var canGetBonusScans: Bool {
        !hiddenKeysUser.socialShare || hiddenKeysUser.referralsCount < hiddenKeysUser.referralsLimit
    }

    private var tip: String {
        hiddenKeysUser.celebrity.hint
    }

    private var isCompleted: Bool {
        hiddenKeysUser.celebrity.status == .completed
    }

    private var invitationLink: String {
        ConfigManager.shared.general.webAppURL.appendingPathComponent("r/\(hiddenKeysUser.referralCode)").absoluteString
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PullToCloseWrapperView(action: onClose) {
                ZStack(alignment: .top) {
                    Image(.hiddenKeysBg)
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
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
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $isScanSheetPresented) {
            HiddenKeysScanView(
                onClose: { isScanSheetPresented = false },
                onViewWallet: {
                    isScanSheetPresented = false
                    onViewWallet()
                }
            )
            .interactiveDismissDisabled()
        }
    }

    var mainSheetContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                HiddenKeysStatusChip(status: hiddenKeysUser.celebrity.status)
                Text("Hidden keys")
                    .h1()
                    .foregroundStyle(.invertedDark)
                    .padding(.top, 12)
                Text("Find a face")
                    .additional1()
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Gradients.purpleText)
                if !isCompleted {
                    Text("Somewhere out on the open web, one famous face carries a key sealed inside its ZK-vector. Test any image you find, and the first player to prove the match claims the prize. Ready to hunt?")
                        .body4()
                        .foregroundStyle(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)
                }
            }
            if !tip.isEmpty && !isCompleted {
                scanTip
            }
            HorizontalDivider()
            if isCompleted {
                hiddenFaceBlock
            } else {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Available")
                            .subtitle6()
                            .foregroundStyle(.textPrimary)
                        HStack(spacing: 4) {
                            Text(verbatim: "\(totalAttemptsLeft)")
                                .h4()
                                .foregroundStyle(Gradients.purpleText)
                            Text("scans")
                                .body4()
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    Spacer()
                    scanActions
                }
            }
        }
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 8)
        .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
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
            if hasAttempts {
                AppButton(
                    variant: .primary,
                    text: "Scan",
                    leftIcon: .userFocus,
                    width: 160,
                    action: { isScanSheetPresented = true }
                )
                .controlSize(.large)
                .disabled(!hasAttempts)
            } else if canGetBonusScans {
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
            } else {
                HStack(spacing: 12) {
                    Image(.lock2Line)
                        .iconLarge()
                    CountdownView(endTimestamp: hiddenKeysUser.resetTime)
                        .buttonLarge()
                }
                .padding(18)
                .frame(width: 160)
                .background(.bgComponentDisabled, in: RoundedRectangle(cornerRadius: 20))
                .foregroundStyle(.textDisabled)
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
                    .iconLarge()
                    .padding(16)
                    .foregroundStyle(.additionalPurple)
                    .background(.additionalPurple.opacity(0.05), in: Circle())
                Text("Bonus scan")
                    .h3()
                    .foregroundStyle(.textPrimary)
                    .padding(.top, 20)
                Text("Out of daily scans? Earn extra scans for every friend who joins and a one-time by sharing the hunt")
                    .body3()
                    .foregroundStyle(.textSecondary)
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
                        Text(hiddenKeysUser.socialShare ? "Shared" : "+1 scan")
                            .body5()
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: {
                        isShareSheetPresented = true
                        Task {
                            await getExtraAttempt()
                        }
                    }) {
                        Text("Share")
                            .buttonMedium()
                            .foregroundStyle(.invertedLight)
                    }
                    .frame(width: 100, height: 32)
                    .background(.textPrimary, in: RoundedRectangle(cornerRadius: 12))
                    .sheet(isPresented: $isShareSheetPresented) {
                        ShareActivityView(activityItems: [
                            UIImage(resource: .hiddenKeysSocialShare),
                            "Think you can spot the famous face and unlock the key? Join the hunt in rariMe now!\n\n\(invitationLink)"
                        ])
                    }
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
                        Text("\(hiddenKeysUser.referralsCount)/\(hiddenKeysUser.referralsLimit) invited")
                            .body5()
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ShareLink(
                        item: URL(string: invitationLink)!,
                        subject: Text("Invite to Hidden Keys"),
                        message: Text("Ready to test faces for hidden keys? Tap my invite, get free scans, and let’s race for the prize!\n\n\(invitationLink)")
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
        .background(.bgSurface1)
    }

    private var hiddenFaceBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hidden face:")
                .subtitle6()
                .foregroundStyle(.textPrimary)
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: hiddenKeysUser.celebrity.image)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.bgComponentPrimary)
                        .frame(width: 80, height: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(hiddenKeysUser.celebrity.title)
                        .h5()
                        .foregroundStyle(.textPrimary)
                    Text(hiddenKeysUser.celebrity.description)
                        .body5()
                        .foregroundStyle(.textSecondary)
                }
            }
            HorizontalDivider()
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text("Winner:")
                        .subtitle6()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Text(verbatim: Ethereum.formatAddress(hiddenKeysUser.celebrity.winner))
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                HStack(spacing: 8) {
                    Text("Prize:")
                        .subtitle6()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    Text(String(FIND_FACE_ETH_REWARD))
                        .body4()
                        .foregroundStyle(.textSecondary)
                    Image(.ethereum)
                        .iconSmall()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.bgBlur)
                .shadow(color: .purpleMain.opacity(0.2), radius: 6, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.purpleBorder, lineWidth: 1)
        )
    }

    private func getExtraAttempt() async {
        do {
            try await viewModel.getExtraAttempt()
        } catch {
            LoggerUtil.common.error("failed to get extra attempt: \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    HiddenKeysView(animation: Namespace().wrappedValue, onClose: {}, onViewWallet: {})
        .environmentObject(HiddenKeysViewModel())
}
