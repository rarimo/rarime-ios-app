import SwiftUI

struct LinearProgressView: View {
    let progress: Double

    var normalizedProgress: Double {
        max(0, min(1, progress))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(.componentPrimary)
                    .frame(width: geometry.size.width, height: 8)
                RoundedRectangle(cornerRadius: 100)
                    .fill(
                        LinearGradient(
                            colors: [.primaryMain, .primaryDark, .primaryDarker],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(normalizedProgress), height: 8)
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        LinearProgressView(progress: 0)
        LinearProgressView(progress: 0.5)
        LinearProgressView(progress: 1)
        LinearProgressView(progress: 1.5)
    }
    .padding()
}
