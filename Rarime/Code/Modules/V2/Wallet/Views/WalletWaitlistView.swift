import SwiftUI

enum WalletWaitlistStep: Int, CaseIterable {
    case seedPhrases, selfRecovery

    var title: LocalizedStringResource {
        switch self {
        case .seedPhrases: return "No more seed phrases"
        case .selfRecovery: return "ZK Face for self-recovery"
        }
    }
}

struct WalletWaitlistView: View {
    let onClose: () -> Void
    let onJoin: () -> Void
    
    @State private var currentStep = WalletWaitlistStep.seedPhrases
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("An Unforgettable")
                        .h4()
                        .fontWeight(.medium)
                        .foregroundStyle(.textPrimary)
                    Text("Wallet")
                        .h3()
                        .fontWeight(.semibold)
                        .foregroundStyle(.textSecondary)
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
            VStack(spacing: 60) {
                Image(Images.seedPhraseShred)
                    .resizable()
                    .scaledToFit()
                TabView(selection: $currentStep) {
                    ForEach(WalletWaitlistStep.allCases, id: \.self) { item in
                        Text(item.title)
                            .h6()
                            .foregroundStyle(.baseBlack)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                .frame(maxHeight: .infinity, alignment: .center)
                V2StepIndicator(
                    steps: WalletWaitlistStep.allCases.count,
                    currentStep: currentStep.rawValue
                )
            }
            .padding(.bottom, 48)
            // TODO: sync with design system
            Button(action: onJoin) {
                Text("Join early waitlist").buttonLarge().fontWeight(.medium)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
            }
            .background(.baseBlack)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Gradients.greenSecond)
    }
}

#Preview {
    WalletWaitlistView(onClose: {}, onJoin: {})
}
