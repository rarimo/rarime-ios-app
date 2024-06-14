import SwiftUI

private enum ViewState {
    case intro, about
}

struct RewardsIntroView: View {
    let onStart: () -> Void
    @State private var termsChecked = false
    @State private var codeVerified = false

    @State private var code = ""
    @State private var codeErrorMessage = ""
    @State private var isVerifyingCode = false
    @State private var viewState: ViewState = .intro

    private func verifyCode() {
        isVerifyingCode = true
        // TODO: Implement code verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let isValidCode = code != "I"
            codeVerified = isValidCode
            isVerifyingCode = false
            if !isValidCode {
                codeErrorMessage = String(localized: "Invalid invitation code")
            }
        }
    }

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    var body: some View {
        ZStack {
            introView.offset(x: viewState == .intro ? 0 : -screenWidth)
            aboutView.offset(x: viewState == .about ? 0 : screenWidth)
        }
        .animation(.easeInOut, value: viewState)
    }

    var introView: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Join Rewards Program"),
                description: String(localized: "Check your eligibility"),
                icon: Image(Images.rewardCoin).square(110),
                subheader: {
                    if !codeVerified {
                        AppTextField(
                            text: $code,
                            errorMessage: $codeErrorMessage,
                            placeholder: "Enter invitation code",
                            action: {
                                Button(action: verifyCode) {
                                    Image(Icons.arrowRight)
                                        .iconMedium()
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(AppButtonStyle(variant: .primary))
                                .clipShape(RoundedRectangle(cornerRadius: 1000))
                                .disabled(code.isEmpty || isVerifyingCode)
                            }
                        )
                        .controlSize(.large)
                        .disabled(isVerifyingCode)
                    }
                }
            ) {
                if codeVerified {
                    Text("Checking eligibility happens via a scan of your biometric passport.\n\nYour data never leaves the device or is shared with any third party. Proof of citizenship is generated locally using Zero-Knowledge technology.")
                        .body3()
                        .foregroundStyle(.textPrimary)
                    InfoAlert(text: "If you lose access to the device or private keys, you won’t be able to claim future rewards using the same passport") {}
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HOW CAN I GET A CODE?")
                            .overline2()
                            .foregroundStyle(.textSecondary)
                        Text("You must be invited or receive a code from social channels")
                            .body3()
                            .foregroundStyle(.textPrimary)
                    }
                    HStack(spacing: 16) {
                        SocialCard(
                            title: "X",
                            icon: Icons.xCircle,
                            url: URL(string: "https://twitter.com/Rarimo_protocol")!
                        )
                        SocialCard(
                            title: "Discord",
                            icon: Icons.discord,
                            url: URL(string: "https://discord.gg/Bzjm5MDXrU")!
                        )
                    }
                }
            }
            Spacer()
            if codeVerified {
                HorizontalDivider()
                AirdropCheckboxView(checked: $termsChecked)
                    .padding(.horizontal, 20)
                AppButton(text: "Check eligibility", action: onStart)
                    .controlSize(.large)
                    .disabled(!termsChecked)
                    .padding(.horizontal, 20)
            } else {
                Button(action: { viewState = .about }) {
                    Text("Learn more about the program")
                        .buttonSmall()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
    }

    var aboutView: some View {
        ZStack(alignment: .topLeading) {
            Button(action: { viewState = .intro }) {
                Image(Icons.arrowLeft)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
            }
            VStack(spacing: 32) {
                Text("About Reward Program")
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using")
                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW CAN I GET THIS CODE?")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("You must be invited by someone or receive a code that we post on our social channels")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("QUESTION TITLE 2")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("You must be invited by someone or receive a code that we post on our social channels")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("QUESTION TITLE 3")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("You must be invited by someone or receive a code that we post on our social channels")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SocialCard: View {
    let title: String
    let icon: String
    let url: URL

    var body: some View {
        Button(action: { UIApplication.shared.open(url) }) {
            VStack(spacing: 8) {
                Image(icon).square(24)
                Text(title)
                    .buttonSmall()
                    .foregroundStyle(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    RewardsIntroView(onStart: {})
        .environmentObject(ConfigManager())
}
