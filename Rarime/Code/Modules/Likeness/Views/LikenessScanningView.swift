import SwiftUI

struct LikenessScanningView: View {
    @EnvironmentObject private var viewModel: LikenessFaceViewModel

    let onConfirm: (CGImage) -> Void

    @State private var isPictureTaken: Bool = false

    var body: some View {
        ZStack {
            if let face = viewModel.currentFrame {
                Image(decorative: face, scale: 1)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(FaceSquare())
                    .clipped()
                Image(.faceFrame)
                    .square(FaceSquare.SHAPE_SIZE)
                if let mask = viewModel.maskFrame {
                    Image(uiImage: mask)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: -1, y: 1)
                        .clipShape(FaceSquare())
                        .clipped()
                }
            } else {
                FaceSquare()
                    .foregroundStyle(.bgComponentPrimary)
            }
            VStack(spacing: 20) {
                topHint.padding(.top, 50)
                Spacer()
                if isPictureTaken {
                    HStack(spacing: 12) {
                        retakeButton
                        confirmButton
                    }
                } else {
                    takeButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .onAppear(perform: viewModel.startScanning)
    }

    var topHint: some View {
        VStack(spacing: 16) {
            Image(.userFocus)
                .iconLarge()
                .foregroundStyle(.baseWhite)
            Text("Center your face")
                .subtitle5()
                .foregroundStyle(.baseWhite)
        }
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
        Button(action: {
            FeedbackGenerator.shared.impact(.medium)
            onConfirm(viewModel.currentFrame!)
        }) {
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
}

private struct FaceSquare: Shape {
    static let SHAPE_SIZE: CGFloat = 300

    func path(in rect: CGRect) -> Path {
        let rect = CGRect(
            x: rect.midX - FaceSquare.SHAPE_SIZE / 2,
            y: rect.midY - FaceSquare.SHAPE_SIZE / 2,
            width: FaceSquare.SHAPE_SIZE,
            height: FaceSquare.SHAPE_SIZE
        )

        return Path { path in
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: 24, height: 24))
        }
    }
}

#Preview {
    LikenessScanningView(onConfirm: { _ in })
        .environmentObject(LikenessFaceViewModel())
}
