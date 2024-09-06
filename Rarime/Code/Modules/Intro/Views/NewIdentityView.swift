import SwiftUI

struct NewIdentityView: View {
    @EnvironmentObject private var userManager: UserManager
    
    let onBack: () -> Void
    let onNext: () -> Void
    
    @State private var isManualBackup = false
    @State private var isCopied = false
    @State private var isSubmitting = false
    
    @State private var cancelables: [Task<Void, Never>] = []
    
    var body: some View {
        ZStack {
            if isManualBackup {
                keysView
            } else {
                backupView
            }
        }
        // TODO: Somehow it's called twice, we need to find why, I've made a quick hack, but it's better to find its source
        .onAppear(perform: createNewUser)
        .onDisappear(perform: cleanup)
    }
    
    var keysView: some View {
        IdentityStepLayoutView(
            title: String(localized: "Your Private Key"),
            onBack: {
                userManager.user = nil
                isManualBackup = false
            },
            nextButton: {
                if let user = userManager.user {
                    AppButton(
                        text: "Continue",
                        rightIcon: Icons.arrowRight,
                        action: {
                            do {
                                try user.save()
                            } catch {
                                LoggerUtil.intro.error("failed to save user: \(error.localizedDescription, privacy: .public)")
                                
                                userManager.user = nil
                                
                                onBack()
                                return
                            }
                            
                            onNext()
                        }
                    ).controlSize(.large)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
        ) {
            CardContainer {
                VStack(spacing: 20) {
                    if let user = userManager.user {
                        ZStack {
                            Text(user.secretKey.hex)
                                .body3()
                                .foregroundStyle(.textPrimary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(.componentPrimary)
                        .cornerRadius(8)
                        copyButton
                    } else {
                        ProgressView()
                            .padding(.vertical, 20)
                    }
                    HorizontalDivider()
                    InfoAlert(text: "Please store the private key safely and do not share it with anyone. If you lose this key, you will not be able to recover the account and will lose access forever.") {}
                }
            }
        }
    }
    
    var backupView: some View {
        ZStack(alignment: .topLeading) {
            Button(action: onBack) {
                Image(Icons.arrowLeft)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            VStack(alignment: .center, spacing: 32) {
                VStack {
                    Image(Icons.cloud)
                        .square(72)
                        .foregroundStyle(.primaryDarker)
                }
                .padding(40)
                .background(.primaryLighter)
                .clipShape(Circle())
                VStack(spacing: 12) {
                    Text("Back up your account")
                        .h4()
                        .foregroundStyle(.textPrimary)
                    Text("Your account is not backed up. If you lose your device, you will lose access to your account")
                        .body2()
                        .foregroundStyle(.textSecondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                Spacer()
                VStack(spacing: 16) {
                    HorizontalDivider()
                    VStack(spacing: 8) {
                        AppButton(
                            text: "Back up with iCloud",
                            action: backUpUserSecretKey
                        )
                        .controlSize(.large)
                        .disabled(isSubmitting)
                        AppButton(
                            variant: .tertiary,
                            text: "Back up manually",
                            action: { isManualBackup = true }
                        )
                        .controlSize(.large)
                        .disabled(isSubmitting)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
            .padding(.bottom, 16)
        }
        .background(.backgroundPure)
    }
    
    var copyButton: some View {
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
            HStack {
                Image(isCopied ? Icons.check : Icons.copySimple).iconMedium()
                Text(isCopied ? "Copied" : "Copy to clipboard").buttonMedium()
            }
            .foregroundStyle(.textPrimary)
        }
    }
    
    func backUpUserSecretKey() {
        isSubmitting = true
        Task { @MainActor in
            defer { isSubmitting = false }

            do {
                let isICloudAvailable = try await CloudStorage.shared.isICloudAvailable()

                if !isICloudAvailable {
                    AlertManager.shared.emitError(.unknown(String(localized: "iCloud is not available")))
                    
                    return
                }

                let isSaved = try await userManager.user?.saveUserPrivateKeyToCloud() ?? false

                if !isSaved {
                    AlertManager.shared.emitError(.unknown(String(localized: "Backup already exists, try restore instead")))
                    
                    return
                }

                saveUser()
            } catch {
                LoggerUtil.common.error("back up error: \(error, privacy: .public)")
                AlertManager.shared.emitError(.unknown(String(localized: "Failed to register, try again later")))
            }
        }
    }
    
    func createNewUser() {
        if userManager.user != nil {
            return
        }
        
        let cancelable = Task { @MainActor in
            do {
                try userManager.createNewUser()
                
                LoggerUtil.intro.info("New user created: \(userManager.userAddress, privacy: .public)")
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to create new user: \(error.localizedDescription, privacy: .public)")
                
                AlertManager.shared.emitError(.userCreationFailed)
            }
        }
        
        cancelables.append(cancelable)
    }
    
    func saveUser() {
        do {
            try userManager.user?.save()
        } catch {
            LoggerUtil.intro.error("failed to save user: \(error.localizedDescription, privacy: .public)")
            userManager.user = nil
            onBack()
            return
        }

        onNext()
    }
    
    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
}

#Preview {
    NewIdentityView(onBack: {}, onNext: {})
        .environmentObject(UserManager())
}
