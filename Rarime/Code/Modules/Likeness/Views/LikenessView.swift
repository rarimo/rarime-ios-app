import SwiftUI

struct LikenessView: View {
    @StateObject private var viewModel = LikenessViewModel()

    var body: some View {
        VStack {
            if let face = viewModel.currentFrame {
                ZStack {
                    Image(decorative: face, scale: 1)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: 76)
                    Image(decorative: face, scale: 1)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(FaceOval())
                        .clipped()
                }
                .scaleEffect(x: -1, y: 1)
            }
        }
        .onAppear {
            viewModel.startScanning()

            if PreviewUtils.isPreview {
                doPreviewSetup()
            }
        }
        .onDisappear {
            viewModel.stopScanning()

            viewModel.clearImages()
        }
    }

    private func doPreviewSetup() {
        viewModel.currentFrame = UIImage(resource: .debugFace).cgImage!
    }
}

private struct FaceOval: Shape {
    private static let SHAPE_WIDTH = 290
    private static let SHAPE_HEIGHT = 395

    func path(in rect: CGRect) -> Path {
        let ovalRect = CGRect(
            x: Int(rect.midX) - FaceOval.SHAPE_WIDTH / 2,
            y: Int(rect.midY) - FaceOval.SHAPE_HEIGHT / 2,
            width: FaceOval.SHAPE_WIDTH,
            height: FaceOval.SHAPE_HEIGHT
        )

        return Path { path in
            path.addEllipse(in: ovalRect)
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: LikenessView.init)
}
