import SwiftUI

struct CirclesLoader: View {
    var size: CGFloat = 4
    var fillColor: Color = .warningDark

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0 ..< 3) { index in
                Circle()
                    .fill(fillColor)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .offset(y: isAnimating ? size : -size)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(0.15 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}

#Preview {
    VStack(spacing: 24) {
        CirclesLoader()
        CirclesLoader(size: 8, fillColor: .errorDark)
    }
}
