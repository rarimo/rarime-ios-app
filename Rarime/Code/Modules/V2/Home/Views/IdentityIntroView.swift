import SwiftUI

struct IdentityIntroView: View {
    let onClose: () -> Void
    let onStart: () -> Void
    
    var body: some View {
        VStack() {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your Device")
                        .h4()
                        .fontWeight(.medium)
                        .foregroundStyle(.textPrimary)
                    Text("Your Identity")
                        .h3()
                        .fontWeight(.semibold)
                        .foregroundStyle(.textSecondary)
                }
                .padding(.top, 20)
                .fixedSize(horizontal: true, vertical: false)
                
                Spacer()
                
                Image(Icons.close)
                    .square(20)
                    .foregroundStyle(.baseBlack)
                    .padding(10)
                    .background(.baseBlack.opacity(0.03))
                    .cornerRadius(100)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .onTapGesture { onClose() }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            Image(Images.handWithPhone)
                .resizable()
                .scaledToFit()
                .scaleEffect(0.9, anchor: .trailing)
            
            Spacer()
            
            Text("This app is where you privately store your digital identities, enabling you to go incognito across the web.")
                .body1()
                .foregroundStyle(.baseBlack.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            
            // TODO: sync with design system
            Button(action: onStart) {
                Text("Let's start").buttonLarge().fontWeight(.medium)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
            }
            .background(.baseBlack)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .frame(maxHeight: .infinity)
        .background(Gradients.greenFirst)
    }
}

#Preview {
    IdentityIntroView(onClose: {}, onStart: {})
}
