
import SwiftUI

struct V2ClaimTokensView: View {
    @EnvironmentObject private var configManager: ConfigManager
    
    let onClose: () -> Void
    let onClaim: () -> Void
    
    var animation: Namespace.ID
    
    private var termsURL: String {
        configManager.general.termsOfUseURL.absoluteString
    }

    private var privacyURL: String {
        configManager.general.privacyPolicyURL.absoluteString
    }

    private var airdropTermsURL: String {
        configManager.general.airdropTerms.absoluteString
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AppIconButton(icon: Icons.closeFill, action: onClose)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.top, .trailing], 20)
            Image(Images.rarimoTokens)
                .resizable()
                .scaledToFit()
                .padding(.top, 54)
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Claim")
                        .h1()
                        .foregroundStyle(.baseBlack)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.title,
                            in: animation,
                            properties: .position
                        )
                    Text("10 RMO")
                        .additional1()
                        .foregroundStyle(.baseBlack.opacity(0.4))
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.subtitle,
                            in: animation,
                            properties: .position
                        )
                }
                Text("This app is where you privately store your digital identities, enabling you to go incognito across the web.")
                    .body3()
                    .foregroundStyle(.baseBlack.opacity(0.5))
                AppButton(variant: .secondary, text: "Claim", action: onClaim)
                    .controlSize(.large)
                (
                    Text("By continue, you are agreeing to ") +
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
    }
}

#Preview {
    V2ClaimTokensView(onClose: {}, onClaim: {}, animation: Namespace().wrappedValue)
        .environmentObject(ConfigManager())
}
