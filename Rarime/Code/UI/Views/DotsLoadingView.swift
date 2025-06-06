import SwiftUI

struct DotsLoadingView: View {
    let size: CGFloat
    let spacing: CGFloat
    let animationDuration: Double
    let dotCount: Int

    @State private var animate = false

    init(
        size: CGFloat = 10,
        spacing: CGFloat = 8,
        animationDuration: Double = 0.6,
        dotCount: Int = 3
    ) {
        self.size = size
        self.spacing = spacing
        self.animationDuration = animationDuration
        self.dotCount = dotCount
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< dotCount, id: \.self) { index in
                Circle()
                    .frame(width: size, height: size)
                    .scaleEffect(animate ? 0.5 : 1)
                    .opacity(animate ? 0.3 : 1)
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever()
                            .delay(Double(index) * (animationDuration / Double(dotCount))),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    DotsLoadingView()
}
