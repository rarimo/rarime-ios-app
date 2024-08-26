import SwiftUI

struct CongratsView: View {
    @EnvironmentObject private var userManager: UserManager
    
    var open: Bool
    var isClaimed: Bool
    var onClose: () -> Void
    
    private var title: String {
        if isClaimed {
            return String(localized: "Congrats!")
        }
        
        if userManager.registerZkProof != nil {
            return String(localized: "Congrats!")
        }
        
        return String(localized: "You’ve joined the waitlist")
    }

    private var description: String {
        if isClaimed {
            return String(localized: "You’ve reserved \(PASSPORT_RESERVE_TOKENS.formatted()) RMO tokens")
        }
        
        if userManager.registerZkProof != nil {
            return String(localized: "You successfully registered your identity!")
        }

        return String(localized: "You will be notified once your country is added")
    }

    var body: some View {
        ZStack {
            if open {
                ZStack {
                    ZStack(alignment: .top) {
                        Image(Images.confetti)
                            .resizable()
                            .frame(width: 220, height: 160)
                        VStack(spacing: 20) {
                            if isClaimed {
                                Image(Images.rewardCoin).square(100)
                            } else {
                                Image(Icons.check)
                                    .square(24)
                                    .foregroundStyle(.backgroundPure)
                                    .padding(28)
                                    .background(.successMain)
                                    .clipShape(Circle())
                            }
                            VStack(spacing: 8) {
                                Text(title)
                                    .h6()
                                    .foregroundStyle(.textPrimary)
                                Text(description)
                                    .body2()
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.textSecondary)
                            }
                            HorizontalDivider()
                            VStack(spacing: 4) {
                                AppButton(variant: .primary, text: isClaimed ? "Thanks!" : "Okay", action: onClose)
                                    .controlSize(.large)
                                if isClaimed {
                                    ShareLink(
                                        // TODO: update content
                                        item: URL(string: "https://rarime.com")!,
                                        subject: Text("RariMe Rewards"),
                                        message: Text("Participate and get rewarded: https://rarime.com")
                                    ) {
                                        HStack(spacing: 8) {
                                            Image(Icons.share).iconMedium()
                                            Text("Share Achievements").buttonLarge()
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 48.0)
                                        .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 1000.0))
                                        .foregroundStyle(.textPrimary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.backgroundPure, in: RoundedRectangle(cornerRadius: 24))
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.baseBlack.opacity(0.1))
            }
        }
        .animation(.easeOut, value: open)
    }
}

#Preview {
    CongratsView(
        open: true,
        isClaimed: false,
        onClose: {}
    )
    .environmentObject(UserManager())
}
