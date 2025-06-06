import SwiftUI

struct LikenessFaceImageView: View {
    let image: UIImage

    // HACK: Remove background is available only in iOS 17,
    // so we just clip the image to a circle in iOS 16.
    var faceClipShape: AnyShape {
        if #available(iOS 17, *) {
            AnyShape(Rectangle())
        } else {
            AnyShape(Circle())
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.bgPurple)
                .frame(width: 265, height: 212)
                .clipShape(
                    .rect(
                        topLeadingRadius: 96,
                        bottomLeadingRadius: 24,
                        bottomTrailingRadius: 96,
                        topTrailingRadius: 24
                    )
                )
                .offset(x: -12, y: 0)
            ZStack {
                Image(uiImage: VisionUtils.removeBackground(image))
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.1)
                    .scaleEffect(x: -1, y: 1)
                    .brightness(0.05)
                    .contrast(1.1)
                    .saturation(1.1)
            }
            .frame(width: 268, height: 268)
            .clipShape(faceClipShape)
        }
    }
}

#Preview {
    LikenessFaceImageView(image: UIImage(resource: .debugFace))
}
