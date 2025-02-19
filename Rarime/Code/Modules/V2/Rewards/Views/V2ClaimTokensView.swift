
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
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Claim")
                        .h4()
                        .fontWeight(.medium)
                        .foregroundStyle(.textPrimary)
                        .matchedGeometryEffect(id: AnimationNamespaceIds.title, in: animation)
                    Text("10 RMO")
                        .h3()
                        .fontWeight(.semibold)
                        .foregroundStyle(.textSecondary)
                        .matchedGeometryEffect(id: AnimationNamespaceIds.subtitle, in: animation)
                }
                .padding(.top, 20)
                Spacer()
                Image(Icons.close)
                    .square(20)
                    .foregroundStyle(.baseBlack)
                    .padding(10)
                    .background(.baseBlack.opacity(0.03))
                    .cornerRadius(100)
                    .onTapGesture { onClose() }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            Spacer()
            Image(Images.rarimoTokens)
                .resizable()
                .scaledToFit()
                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
            Spacer()
            Text("Start building your incognito profile and earn rewards as an early community member.")
                .body1()
                .foregroundStyle(.baseBlack.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            VStack(spacing: 8) {
                // TODO: sync with design system
                Button(action: onClaim) {
                    Text("Claim").buttonLarge().fontWeight(.medium)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                }
                .background(.baseBlack)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.bottom, 8)
                (
                    Text("By continue, you are agreeing to ") +
                        Text(.init("[\(String(localized: "RariMe General Terms & Conditions"))](\(termsURL))")).underline() +
                        Text(", ") +
                        Text(.init("[\(String(localized: "RariMe Privacy Notice"))](\(privacyURL))")).underline() +
                        Text(" and ") +
                        Text(.init("[\(String(localized: "Rarimo Airdrop Program Terms & Conditions"))](\(airdropTermsURL))")).underline()
                )
                .body4()
                .tint(.textSecondary)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .background(
            Gradients.greenSecond
                .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    V2ClaimTokensView(onClose: {}, onClaim: {}, animation: Namespace().wrappedValue)
}
