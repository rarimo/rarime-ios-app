import SwiftUI

struct IntroStepView: View {
    let step: IntroStep

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 24) {
                ZStack {
                    LottieView(animation: step.animation)
                        .frame(maxWidth: step.animationWidth)
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading, spacing: 16) {
                    Text(step.title).h2().foregroundStyle(.textPrimary)
                    Text(step.text).body3()
                        .foregroundStyle(.textSecondary)
                }
                .padding(.horizontal, 24)
            }
            Spacer()
        }
    }
}

#Preview {
    IntroStepView(step: .welcome)
}
