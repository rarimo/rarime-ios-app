import SwiftUI

struct WalletWaitlistView: View {
    let onClose: () -> Void
    let onJoin: () -> Void
    
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
            Spacer()
            VStack(spacing: 60) {
                Image(Images.seedPhraseShred)
                    .resizable()
                    .scaledToFit()
                Text("No more seed phrases")
                    .subtitle1()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
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
        .background(Gradients.gradientFourth)
    }
}

#Preview {
    WalletWaitlistView(onClose: {}, onJoin: {})
}
