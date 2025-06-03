import CloudKit
import SwiftUI

struct RecoveryMethodSelectionView: View {
    @EnvironmentObject private var userManager: UserManager

    let onClose: () -> Void

    @StateObject var viewModel = ICloudRecoveryViewModel()

    @State private var isCopied = false
    @State private var isRewriteAlertPresented = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Recovery Method")
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Spacer()
                Button(action: onClose) {
                    Image(.closeFill)
                        .iconLarge()
                        .foregroundStyle(.textPrimary)
                }
            }
            .padding(.horizontal, 12)
            VStack(spacing: 12) {
                privateKeyCard
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.vertical, 32)
                } else {
                    if viewModel.isICloudAvailable {
                        RecoveryMethodItem(
                            icon: .cloudLine,
                            title: String(localized: "iCloud backup"),
                            description: String(localized: "Backup key stored in iCloud"),
                            isRecommended: true,
                            isDisabled: viewModel.isProcessing
                        ) {
                            AppToggle(isOn: Binding(
                                get: { viewModel.isKeysEqual },
                                set: { val in
                                    Task {
                                        await toggleBackup(val)
                                    }
                                }
                            ))
                        }
                    }
                    RecoveryMethodItem(
                        icon: .emotionHappyLine,
                        title: String(localized: "zkFace"),
                        description: String(localized: "Biometric facial key"),
                        isRecommended: false,
                        isDisabled: true
                    ) {
                        soonBadge
                    }
                    RecoveryMethodItem(
                        icon: .box3Line,
                        title: String(localized: "Objects"),
                        description: String(localized: "Make any object your key"),
                        isRecommended: false,
                        isDisabled: true
                    ) {
                        soonBadge
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .onAppear {
            Task { await viewModel.loadBackupStatus() }
        }
        .alert(
            "iCloud backup already exists",
            isPresented: $isRewriteAlertPresented,
            actions: {
                Button("No", role: .cancel) {
                    isRewriteAlertPresented = false
                }
                Button("Yes", role: .destructive) {
                    isRewriteAlertPresented = false
                    Task {
                        await viewModel.deleteBackup()
                        await viewModel.backUpUserSecretKey()
                    }
                }
            },
            message: {
                Text("Overwrite your iCloud backup? This will replace the existing backup with the current private key.")
            }
        )
    }

    private var privateKeyCard: some View {
        CardContainer {
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    Image(.key2Line)
                        .iconMedium()
                    Text("Private Key")
                        .subtitle5()
                    Spacer()
                }
                .foregroundStyle(.textPrimary)
                VStack(alignment: .leading, spacing: 20) {
                    if let user = userManager.user {
                        Text(user.secretKey.hex)
                            .body4()
                            .foregroundStyle(.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HorizontalDivider()
                    copyButton
                }
                .padding(20)
                .background(.bgSurface1, in: RoundedRectangle(cornerRadius: 12))
                .applyShadows([
                    ShadowConfig(color: .black.opacity(0.04), radius: 1, x: 0, y: 0),
                    ShadowConfig(color: .black.opacity(0.04), radius: 2, x: 0, y: 2),
                    ShadowConfig(color: .black.opacity(0.04), radius: 4, x: 0, y: 4),
                    ShadowConfig(color: .black.opacity(0.04), radius: 8, x: 0, y: 8),
                ])
                .padding(.top, 4)
                Text("Please store the private key safely and do not share it with anyone. If you lose this key, you will not be able to recover the account and will lose access forever.")
                    .body5()
                    .foregroundStyle(.textSecondary)
            }
        }
    }

    private var copyButton: some View {
        Button(action: {
            if isCopied { return }
            guard let user = userManager.user else { return }

            UIPasteboard.general.string = user.secretKey.hex
            isCopied = true
            FeedbackGenerator.shared.impact(.medium)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCopied = false
            }
        }) {
            HStack(spacing: 12) {
                Spacer()
                Image(isCopied ? .check : .fileCopyLine)
                    .iconMedium()
                Text(isCopied ? "Copied" : "Copy")
                    .buttonMedium()
                Spacer()
            }
            .foregroundStyle(.textPrimary)
        }
    }

    private var soonBadge: some View {
        Text("Soon")
            .overline3()
            .foregroundStyle(.baseBlack)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Gradients.lightGreenBg, in: Capsule())
    }

    private func toggleBackup(_ isOn: Bool) async {
        if viewModel.isProcessing { return }

        if !isOn {
            await viewModel.deleteBackup()
            return
        }

        if viewModel.cloudKey == nil {
            await viewModel.backUpUserSecretKey()
        } else {
            isRewriteAlertPresented = true
        }
    }
}

#Preview {
    ZStack {}
        .dynamicSheet(isPresented: .constant(true), fullScreen: true) {
            RecoveryMethodSelectionView(onClose: {})
                .environmentObject(UserManager.shared)
        }
}
