import ConfettiSwiftUI
import SwiftUI

struct PrizeScanSuccessView: View {
    @EnvironmentObject private var prizeScanViewModel: PrizeScanViewModel

    let onViewWallet: () -> Void

    @State private var confettiTrigger = 0
    @State private var progress: Int = 0

    @State private var isClaiming = false
    @State private var isClaimed = false

    private var prizeScanUser: PrizeScanUser {
        prizeScanViewModel.user ?? PrizeScanUser.empty()
    }

    private var imageToShare: Data {
        // TODO: use different image for sharing
        UIImage(named: "HiddenPrizeBg")!.pngData()!
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
            ZStack(alignment: .top) {
                Image(.hiddenPrizeBg)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                AsyncImage(
                    url: URL(string: prizeScanUser.celebrity.image),
                    content: { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 118, height: 135)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                            .padding(.top, 172)
                            .ignoresSafeArea()
                    },
                    placeholder: {
                        ProgressView()
                            .frame(width: 118, height: 135)
                            .background(.bgBlur.opacity(0.2))
                            .backgroundBlur(bgColor: .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.top, 172)
                            .ignoresSafeArea()
                    }
                )
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
                        Text(verbatim: String(PRIZE_SCAN_ETH_REWARD))
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
                                    .square(24)
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
                        .stroke(.purpleLighter, lineWidth: 1)
                )
                if isClaimed {
                    VStack(spacing: 8) {
                        Spacer()
                        AppButton(variant: .quartenary, text: "View Wallet", action: onViewWallet)
                            .controlSize(.large)
                        ShareLink(
                            item: imageToShare,
                            subject: Text("I've found the key!"),
                            preview: SharePreview("I've found the key!", image: Image(uiImage: UIImage(data: imageToShare)!))
                        ) {
                            Text("Share")
                                .buttonLarge()
                                .foregroundStyle(.invertedLight)
                                .padding(18)
                                .frame(maxWidth: .infinity, maxHeight: 56)
                                .background(.invertedDark, in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }
            .padding(.top, 304)
            .padding(.horizontal, 24)
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
            rainHeight: UIScreen.main.bounds.height,
            openingAngle: Angle.degrees(0),
            closingAngle: Angle.degrees(180),
            radius: 480
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                confettiTrigger += 1
            }
        }
    }

    func claimReward() async {
        do {
            isClaiming = true
            try await prizeScanViewModel.claimReward { progress in
                self.progress = Int(progress.fractionCompleted * 100)
            }
            isClaimed = true
        } catch {
            LoggerUtil.common.error("PrizeScan: Failed to claim reward: \(error)")
            AlertManager.shared.emitError("Failed to claim reward, try again")
        }

        isClaiming = false
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            PrizeScanSuccessView(onViewWallet: {})
                .environmentObject(PrizeScanViewModel())
        }
}
