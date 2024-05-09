import SwiftUI

struct NewIdentityView: View {
    @EnvironmentObject private var userManager: UserManager
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var isCopied = false
    
    @State private var cancelables: [Task<Void, Never>] = []

    var body: some View {
        IdentityStepLayoutView(
            title: String(localized: "Your Private Key"),
            onBack: {
                userManager.user = nil
                
                onBack()
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
                                LoggerUtil.intro.error("failed to save user: \(error)")
                                
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
        .onAppear(perform: createNewUser)
        .onDisappear(perform: cleanup)
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
    
    func createNewUser() {
        let cancelable = Task { @MainActor in
            do {
                try userManager.createNewUser()
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to create new user: \(error)")
            }
        }
        
        cancelables.append(cancelable)
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
