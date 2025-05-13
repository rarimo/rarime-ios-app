import SwiftUI

struct FaceLikenessView: View {
    let onConfirm: (CGImage) -> Void
    let onBack: () -> Void

    @StateObject var viewModel = LikenessFaceViewModel()
    @State private var isPictureTaken: Bool = false

    var body: some View {
        ZStack {
            ZStack {
                facePreview
                    .scaleEffect(x: -1, y: 1)
                VStack(spacing: 0) {
                    topHint.padding(.top, 50)
                    Spacer()
                    bottomHint.padding(.bottom, 20)
                    if isPictureTaken {
                        confirmAndRetakeButton
                    } else {
                        takeButton
                    }
                }
            }
            closeButton
        }
        .background(.baseBlack)
        .onAppear(perform: viewModel.startScanning)
        .onDisappear(perform: cleanup)
    }

    var topHint: some View {
        VStack(spacing: 25) {
            Image(uiImage: UIImage(resource: .faceScan))
            Text("Keep your face in the frame")
                .subtitle5()
                .foregroundStyle(.white)
        }
    }

    var facePreview: some View {
        ZStack {
            if let face = viewModel.currentFrame {
                blurredFace(Image(decorative: face, scale: 1))
                if let mask = viewModel.maskFrame {
                    Image(uiImage: mask)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: -1, y: 1)
                }
            } else {
                FaceOval()
                    .foregroundStyle(.bgComponentPrimary)
            }
        }
    }

    func blurredFace(_ image: Image) -> some View {
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
                Text("Take a picture")
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

    var closeButton: some View {
        Button(action: {
            cleanup()
            onBack()
        }) {
            Image(.closeFill)
                .iconMedium()
                .padding(10)
                .background(.baseBlack.opacity(0.05), in: Circle())
                .foregroundStyle(.baseWhite)
        }
        .padding(.leading, UIScreen.main.bounds.width - 80)
        .padding(.bottom, UIScreen.main.bounds.height - 180)
    }

    func cleanup() {
        viewModel.stopScanning()
        viewModel.clearImages()
    }

    func takePicture() {
        FeedbackGenerator.shared.impact(.medium)
        isPictureTaken = true
        viewModel.pauseScanning()
    }

    func retakePicture() {
        FeedbackGenerator.shared.impact(.medium)
        isPictureTaken = false
        viewModel.startScanning()
    }

    func confirmPicture() {
        FeedbackGenerator.shared.impact(.medium)
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
            FaceLikenessView(onConfirm: { _ in }, onBack: {})
        }
}
