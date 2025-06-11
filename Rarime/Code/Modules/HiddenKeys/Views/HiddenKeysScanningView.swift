import SwiftUI

struct HiddenKeysScanningView: View {
    @EnvironmentObject private var cameraViewModel: HiddenKeysCameraViewModel
    @EnvironmentObject private var hiddenKeysViewModel: HiddenKeysViewModel

    let onSubmit: (_ result: Bool) -> Void

    @State private var isPictureTaken: Bool = false
    @State private var isSubmitting: Bool = false

    var body: some View {
        ZStack {
            if let face = cameraViewModel.currentFrame {
                Image(decorative: face, scale: 1)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .clipShape(FaceSquare())
                    .clipped()
                Image(.faceFrame)
                    .square(FaceSquare.SHAPE_SIZE)
                if let mask = cameraViewModel.maskFrame {
                    Image(uiImage: mask)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
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
        .onAppear(perform: cameraViewModel.startScanning)
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
            Text(isSubmitting ? "Processing..." : "Confirm")
                .foregroundStyle(.baseBlack)
                .buttonLarge()
                .frame(maxWidth: .infinity)
                .padding(18)
                .background(.baseWhite.opacity(isSubmitting ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 20))
        }
        .disabled(isSubmitting)
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
        cameraViewModel.pauseScanning()
    }

    func retakePicture() {
        FeedbackGenerator.shared.impact(.medium)
        isPictureTaken = false
        cameraViewModel.startScanning()
    }

    func confirmPicture() {
        FeedbackGenerator.shared.impact(.medium)
        Task { @MainActor in
            isSubmitting = true

            do {
                LoggerUtil.common.info("Submitting guess")

                let isSuccess = try await hiddenKeysViewModel.submitGuess(
                    image: UIImage(cgImage: cameraViewModel.currentFrame!)
                )

                if isSuccess {
                    FeedbackGenerator.shared.notify(.success)
                } else {
                    FeedbackGenerator.shared.notify(.error)
                }

                onSubmit(isSuccess)
            } catch {
                FeedbackGenerator.shared.notify(.error)
                LoggerUtil.common.error("Failed to submit guess: \(error.localizedDescription, privacy: .public)")
                AlertManager.shared.emitError("Failed to submit guess")

                isPictureTaken = false
                cameraViewModel.startScanning()
            }

            isSubmitting = false
        }
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
    HiddenKeysScanningView(onSubmit: { _ in })
        .environmentObject(HiddenKeysViewModel())
        .environmentObject(HiddenKeysCameraViewModel())
}
