import SwiftUI

struct PrizeScanView: View {
    let onClose: () -> Void
    var animation: Namespace.ID

    @State private var isScanSheetPresented = false
    @State private var isBonusScanSheetPresented = false

    private var hasAttempts: Bool {
        false
    }

    private var canGetBonusScans: Bool {
        true
    }

    private var tip: String? {
        return "I think there's something as light as ether in that face..."
    }

    var body: some View {
        PullToCloseWrapperView(action: onClose) {
            ZStack(alignment: .topTrailing) {
                AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.top, .trailing], 20)
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
        }
        .sheet(isPresented: $isScanSheetPresented) {
            PrizeScanCameraView(
                onClose: { isScanSheetPresented = false }
            )
            .interactiveDismissDisabled()
        }
    }

    var mainSheetContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Hidden prize")
                    .h1()
                    .foregroundStyle(.baseBlack)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.title,
                        in: animation,
                        properties: .position
                    )
                Text("Scan")
                    .additional1()
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(Gradients.purpleText)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.subtitle,
                        in: animation,
                        properties: .position
                    )
                Text("Found hidden prize $1000")
                    .body4()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                    .padding(.top, 12)
                    .matchedGeometryEffect(
                        id: AnimationNamespaceIds.extra,
                        in: animation,
                        properties: .position
                    )
                Text("You have 3 scan attempts every 24 hours, but you can also earn extra scans by sharing and inviting friends.")
                    .body4()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
            }
            if tip != nil {
                scanTip
            }
            HorizontalDivider()
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available")
                        .subtitle6()
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: 2) {
                        Text("3")
                            .h4()
                            .foregroundStyle(Gradients.purpleText)
                        Text("/3 scans")
                            .body4()
                            .foregroundStyle(.textSecondary)
                    }
                }
                Spacer()
                scanActions
            }
        }
        // HACK: prevent pull to close on empty space
        .background(.white.opacity(0.01))
        .padding(.horizontal, 20)
    }

    private var scanTip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(.bulb).iconSmall()
                Text("Tip:").subtitle7()
            }
            Text(verbatim: tip ?? "")
                .body4()
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Gradients.purpleText)
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
                Text("Invite a friend and get 1 bonus scan for each invited friend, or share the post and get 1 bonus scan as a one-time reward.")
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
                    AppButton(
                        text: "Share",
                        width: 100,
                        action: {}
                    )
                    .controlSize(.small)
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
                        Text("+1 scan")
                            .body5()
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    AppButton(
                        text: "Invite",
                        width: 100,
                        action: {}
                    )
                    .controlSize(.small)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
    }
}

#Preview {
    PrizeScanView(onClose: {}, animation: Namespace().wrappedValue)
}
