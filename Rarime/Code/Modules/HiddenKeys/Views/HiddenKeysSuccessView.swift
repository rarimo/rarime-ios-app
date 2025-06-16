import ConfettiSwiftUI
import SwiftUI

struct HiddenKeysSuccessView: View {
    @EnvironmentObject private var hiddenKeysViewModel: HiddenKeysViewModel

    let onViewWallet: () -> Void

    @State private var confettiTrigger = 0
    @State private var progress: Int = 0

    @State private var isClaiming = false
    @State private var isClaimed = false

    @State private var isShareSheetPresented = false

    private var hiddenKeysUser: HiddenKeysUser {
        hiddenKeysViewModel.user ?? HiddenKeysUser.empty()
    }

    private var claimButtonText: String {
        if isClaimed {
            return "Claimed"
        } else if isClaiming {
            return (progress > 0 && progress < 100) ? "Claiming (\(progress)%)" : "Claiming..."
        } else {
            return "Claim"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    Image(.hiddenKeysBg)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    AsyncImage(
                        url: URL(string: hiddenKeysUser.celebrity.image),
                        content: { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width / 3.5, height: geo.size.height / 5.5)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .clipped()
                                .padding(.top, geo.size.height / 4.5)
                                .ignoresSafeArea()
                        },
                        placeholder: {
                            ProgressView()
                                .frame(width: geo.size.width / 3.5, height: geo.size.height / 5.5)
                                .background(.bgBlur.opacity(0.2))
                                .backgroundBlur(bgColor: .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top, geo.size.height / 4.5)
                                .ignoresSafeArea()
                        }
                    )
                }
            }
            .offset(x: 0, y: -80)
            Rectangle()
                .fill(.clear)
                .backgroundBlur(bgColor: .clear)
                .padding(.top, 350)
            VStack(spacing: 32) {
                VStack(spacing: 0) {
                    Text("Congrats!")
                        .h3()
                        .foregroundStyle(.textPrimary)
                    Text("You've found the hidden keys")
                        .body3()
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 260)
                        .padding(.top, 12)
                }
                VStack(spacing: 8) {
                    Text("Your prize:")
                        .subtitle6()
                        .foregroundStyle(.textSecondary)
                    HStack(spacing: 10) {
                        Text(verbatim: String(FIND_FACE_ETH_REWARD))
                            .h3()
                            .foregroundStyle(.textPrimary)
                        Image(.ethereum)
                            .iconMedium()
                    }
                    Button(action: {
                        Task {
                            await claimReward()
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isClaimed {
                                Image(.checkLine)
                                    .iconLarge()
                            }
                            Text(claimButtonText)
                                .buttonLarge()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(18)
                        .foregroundStyle(isClaimed ? .successDark : isClaiming ? .textDisabled : .invertedLight)
                        .background(
                            isClaimed ? .successLighter : isClaiming ? .bgComponentDisabled : .invertedDark,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                    }
                    .padding(.top, 12)
                    .disabled(isClaiming || isClaimed)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.bgBlur)
                        .shadow(color: .purpleMain.opacity(0.2), radius: 6, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.purpleBorder, lineWidth: 1)
                )
                if isClaimed {
                    VStack(spacing: 8) {
                        Spacer()
                        AppButton(variant: .quartenary, text: "View Wallet", action: onViewWallet)
                            .controlSize(.large)
                        AppButton(text: "Share", action: { isShareSheetPresented = true })
                            .controlSize(.large)
                            .sheet(isPresented: $isShareSheetPresented) {
                                ShareActivityView(activityItems: [
                                    UIImage(resource: .hiddenKeysWinnerShare),
                                    "Hidden keys: found. Prize: secured. Who’s next to join the winners’ circle? 🔑🏆"
                                ])
                            }
                    }
                }
            }
            .padding(.top, 304)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(.bgPrimary)
        .confettiCannon(
            trigger: $confettiTrigger,
            num: 300,
            colors: [
                .purpleLighter,
                .purpleLight,
                .purpleMain,
                .purpleDark
            ],
            rainHeight: 1000,
            openingAngle: Angle.degrees(0),
            closingAngle: Angle.degrees(180),
            radius: 480
        )
        .onAppear {
            confettiTrigger += 1
        }
    }

    func claimReward() async {
        do {
            isClaiming = true
            try await hiddenKeysViewModel.claimReward { progress in
                self.progress = Int(progress.fractionCompleted * 100)
            }

            FeedbackGenerator.shared.notify(.success)
            isClaimed = true
        } catch {
            FeedbackGenerator.shared.notify(.error)
            LoggerUtil.common.error("HiddenKeys: Failed to claim reward: \(error)")
            AlertManager.shared.emitError("Failed to claim reward, try again")
        }

        isClaiming = false
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            HiddenKeysSuccessView(onViewWallet: {})
                .environmentObject(HiddenKeysViewModel())
        }
}
