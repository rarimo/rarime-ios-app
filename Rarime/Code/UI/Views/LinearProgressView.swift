import SwiftUI

struct LinearProgressView: View {
    let progress: Double
    let height: CGFloat
    let backgroundFill: AnyShapeStyle
    let foregroundFill: AnyShapeStyle

    init(
        progress: Double,
        height: CGFloat = 8,
        backgroundFill: AnyShapeStyle = AnyShapeStyle(Color.bgComponentPrimary),
        foregroundFill: AnyShapeStyle = AnyShapeStyle(
            LinearGradient(
                colors: [.primaryMain, .primaryDark, .primaryDarker],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    ) {
        self.progress = progress
        self.height = height
        self.backgroundFill = backgroundFill
        self.foregroundFill = foregroundFill
    }

    var normalizedProgress: Double {
        max(0, min(1, progress))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(backgroundFill)
                    .frame(width: geometry.size.width, height: height)
                RoundedRectangle(cornerRadius: 100)
                    .fill(foregroundFill)
                    .frame(width: geometry.size.width * CGFloat(normalizedProgress), height: height)
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
