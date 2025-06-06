import ConfettiSwiftUI
import SwiftUI

struct ClaimTokensView: View {
    @EnvironmentObject private var configManager: ConfigManager
    
    @StateObject var rewardsViewModel = RewardsViewModel()
    
    let onClose: () -> Void
    let pointsBalance: PointsBalanceRaw?
    
    var animation: Namespace.ID
    
    @State private var confettiTrigger = 0
    @State private var isTokensClaiming = false
    
    private var termsURL: String {
        configManager.general.termsOfUseURL.absoluteString
    }

    private var privacyURL: String {
        configManager.general.privacyPolicyURL.absoluteString
    }
    
    private var airdropTermsURL: String {
        configManager.general.airdropTerms.absoluteString
    }
    
    private var claimButtonText: LocalizedStringResource {
        if isTokensClaiming {
            return "Claiming..."
        } else if rewardsViewModel.isTokensClaimed {
            return "Claimed"
        } else {
            return "Claim"
        }
    }
    
    private var isBalanceSufficient: Bool {
        pointsBalance != nil && pointsBalance?.amount ?? 0 > 0
    }
    
    var body: some View {
        PullToCloseWrapperView(action: onClose) {
            VStack(spacing: 0) {
                AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.top, .trailing], 20)
                Image(Images.rarimoTokens)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 96)
                    .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(isBalanceSufficient ? "Reserved" : "Upcoming")
                            .h1()
                            .foregroundStyle(.baseBlack)
                            .matchedGeometryEffect(
                                id: AnimationNamespaceIds.title,
                                in: animation,
                                properties: .position
                            )
                        Text(isBalanceSufficient ? "\(pointsBalance?.amount ?? 0) RMO" : "RMO")
                            .additional1()
                            .foregroundStyle(.baseBlack.opacity(0.4))
                            .matchedGeometryEffect(
                                id: AnimationNamespaceIds.subtitle,
                                in: animation,
                                properties: .position
                            )
                    }
//                    TODO: uncomment after desing and flow impl
//                    Text("This app is where you privately store your digital identities, enabling you to go incognito across the web.")
//                        .body3()
//                        .foregroundStyle(.baseBlack.opacity(0.5))
//                    AppButton(
//                        variant: .secondary,
//                        text: claimButtonText,
//                        leftIcon: rewardsViewModel.isTokensClaimed ? Icons.checkLine : nil,
//                        action: onClaimTokens
//                    )
//                    .controlSize(.large)
//                    .disabled(rewardsViewModel.isTokensClaimed || isTokensClaiming)
                    (
                        Text(.init("[\(String(localized: "RariMe General Terms & Conditions"))](\(termsURL))")).underline() +
                            Text(", ") +
                            Text(.init("[\(String(localized: "RariMe Privacy Notice"))](\(privacyURL))")).underline() +
                            Text(" and ") +
                            Text(.init("[\(String(localized: "Rarimo Airdrop Program Terms & Conditions"))](\(airdropTermsURL))")).underline()
                    )
                    .body5()
                    .tint(.baseBlack.opacity(0.5))
                    .foregroundStyle(.baseBlack.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding([.top, .horizontal], 24)
                .padding(.bottom, 8)
            }
            .background(
                Gradients.gradientThird
                    .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                    .ignoresSafeArea()
            )
            .confettiCannon(
                trigger: $confettiTrigger,
                num: 300,
                colors: [.secondaryDarker, .secondaryDark, .secondaryMain, .successDarker, .successDark],
                rainHeight: UIScreen.main.bounds.height,
                openingAngle: Angle.degrees(0),
                closingAngle: Angle.degrees(180),
                radius: 480
            )
        }
    }
    
//    private func onClaimTokens() {
//        isTokensClaiming = true
//
//        // TODO: remove it after flow impl
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            rewardsViewModel.isTokensClaimed = true
//            isTokensClaiming = false
//            confettiTrigger += 1
//        }
//    }
}

#Preview {
    ClaimTokensView(onClose: {}, pointsBalance: nil, animation: Namespace().wrappedValue)
        .environmentObject(ConfigManager())
}
