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
                    ZStack {
                        Text("Beta launch")
                            .body3()
                            .foregroundStyle(.warningDark)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(.warningLight)
                    .clipShape(Capsule())
                    Text(step.title).h4().foregroundStyle(.textPrimary)
                    Text(step.text).body2()
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
