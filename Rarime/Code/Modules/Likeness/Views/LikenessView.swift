import SwiftUI

struct LikenessView: View {
    @StateObject private var viewModel = LikenessViewModel()

    let onConfirm: (CGImage) -> Void

    let onBack: () -> Void

    @State private var isPictureTaken: Bool = false

    var body: some View {
        withCloseButton {
            ZStack {
                facePreview
                    .scaleEffect(x: -1, y: 1)
                VStack {
                    topHint
                        .padding(.top, 50)
                    Spacer()
                    bottomHint
                    if isPictureTaken {
                        confirmAndRetakeButton
                    } else {
                        takeButton
                    }
                }
            }
            .onAppear {
                viewModel.startScanning()

                if PreviewUtils.isPreview {
                    doPreviewSetup()
                }
            }
            .onDisappear(perform: cleanup)
        }
    }

    var topHint: some View {
        VStack(spacing: 25) {
            Image(uiImage: UIImage(resource: .faceScan))
            Text("Turn your head slightly to the left")
                .subtitle5()
                .foregroundStyle(.white)
        }
    }

    var facePreview: some View {
        ZStack {
            if let face = viewModel.currentFrame {
                bluredFace(Image(decorative: face, scale: 1))
            } else {
                FaceOval()
                    .foregroundStyle(.bgComponentPrimary)
            }
        }
    }

    func bluredFace(_ image: Image) -> some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 76)
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(FaceOval())
                .clipped()
        }
    }

    var bottomHint: some View {
        Text("Your face never leaves the device. You create an anonymous record that carries your rules, so AI knows how to treat you")
            .body4()
            .multilineTextAlignment(.center)
            .foregroundStyle(.baseWhite)
            .opacity(0.6)
            .frame(width: 342)
    }

    var takeButton: some View {
        Button(action: takePicture) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.baseWhite)
                    .opacity(0.05)
                Text("Take")
                    .foregroundStyle(.baseWhite)
                    .buttonLarge()
            }
        }
        .frame(width: 350, height: 56)
    }

    var confirmAndRetakeButton: some View {
        HStack(spacing: 10) {
            retakeButton
            confirmButton
        }
    }

    var confirmButton: some View {
        Button(action: confirmPicture) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.baseWhite)
                    .opacity(0.05)
                Text("Confirm")
                    .foregroundStyle(.baseWhite)
                    .buttonLarge()
            }
        }
        .frame(width: 284, height: 56)
    }

    var retakeButton: some View {
        Button(action: retakePicture) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.baseWhite)
                    .opacity(0.05)
                Image(systemName: "arrow.circlepath")
                    .foregroundStyle(.baseWhite)
                    .buttonLarge()
            }
        }
        .frame(width: 56, height: 56)
    }

    func withCloseButton(_ body: () -> some View) -> some View {
        ZStack {
            body()
            VStack {
                Button(action: {
                    cleanup()
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.baseWhite)
                            .opacity(0.05)
                        Image(systemName: "xmark")
                            .foregroundColor(.baseWhite)
                    }
                }
                .frame(width: 40, height: 40)
                .padding(.leading, UIScreen.main.bounds.width - 100)
                .padding(.bottom, UIScreen.main.bounds.height - 200)
            }
        }
    }

    private func doPreviewSetup() {
        viewModel.currentFrame = UIImage(resource: .debugFace).cgImage!
    }

    func cleanup() {
        viewModel.stopScanning()

        viewModel.clearImages()
    }

    func takePicture() {
        FeedbackGenerator.shared.impact(.light)

        isPictureTaken = true

        viewModel.pauseScanning()
    }

    func retakePicture() {
        FeedbackGenerator.shared.impact(.light)

        isPictureTaken = false

        viewModel.startScanning()
    }

    func confirmPicture() {
        FeedbackGenerator.shared.impact(.light)

        let confirmedPicture = viewModel.currentFrame!

        cleanup()

        onConfirm(confirmedPicture)
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
        .sheet(isPresented: .constant(true)) {
            LikenessView(onConfirm: { _ in }, onBack: {})
        }
}
