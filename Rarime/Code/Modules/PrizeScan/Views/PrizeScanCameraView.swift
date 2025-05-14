import SwiftUI

struct PrizeScanCameraView: View {
    let onClose: () -> Void

    @StateObject var viewModel = PrizeScanCameraViewModel()
    @State private var isPictureTaken: Bool = false

    var body: some View {
        ZStack {
            ZStack {
                facePreview
                    .scaleEffect(x: -1, y: 1)
                VStack(spacing: 20) {
                    topHint.padding(.top, 50)
                    Spacer()
                    bottomHint
                    if isPictureTaken {
                        HStack(spacing: 12) {
                            retakeButton
                            confirmButton
                        }
                    } else {
                        takeButton
                    }
                }
                .padding(.horizontal, 16)
            }
            closeButton
        }
        .background(.baseBlack)
        .onAppear(perform: viewModel.startScanning)
        .onDisappear(perform: cleanup)
    }

    var topHint: some View {
        VStack(spacing: 16) {
            Image(.userFocus)
                .iconLarge()
                .foregroundStyle(.baseWhite)
            Text("Center the person's face")
                .subtitle5()
                .foregroundStyle(.baseWhite)
        }
    }

    var facePreview: some View {
        ZStack {
            if let face = viewModel.currentFrame {
                blurredFace(Image(decorative: face, scale: 1))
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
        Text("Tip: I think there's something as light as ether in that face...")
            .body4()
            .multilineTextAlignment(.center)
            .foregroundStyle(.baseWhite.opacity(0.6))
            .padding(.horizontal, 24)
    }

    var takeButton: some View {
        Button(action: takePicture) {
            Text("Take a picture")
                .foregroundStyle(.baseWhite)
                .buttonLarge()
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(.baseWhite.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        }
    }

    var confirmButton: some View {
        Button(action: confirmPicture) {
            Text("Confirm")
                .foregroundStyle(.baseBlack)
                .buttonLarge()
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(.baseWhite, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    var retakeButton: some View {
        Button(action: retakePicture) {
            Image(.arrowCounterClockwise)
                .iconMedium()
                .foregroundStyle(.baseWhite)
                .padding(18)
                .background(.baseWhite.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        }
    }

    var closeButton: some View {
        Button(action: {
            cleanup()
            onClose()
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
        onClose()
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            PrizeScanCameraView(onClose: {})
        }
}
