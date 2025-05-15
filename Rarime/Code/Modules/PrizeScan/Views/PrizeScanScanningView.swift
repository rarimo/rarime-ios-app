import SwiftUI

struct PrizeScanScanningView: View {
    @EnvironmentObject private var viewModel: PrizeScanCameraViewModel
    @EnvironmentObject private var prizeScanViewModel: PrizeScanViewModel

    let onSubmit: (_ result: Bool) -> Void

    @State private var isPictureTaken: Bool = false
    @State private var isSubmitting: Bool = false

    private var tip: String {
        prizeScanViewModel.user?.celebrity?.hint ?? ""
    }

    var body: some View {
        ZStack {
            if let face = viewModel.currentFrame {
                Image(decorative: face, scale: 1)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(FaceOval())
                    .clipped()
                    .scaleEffect(x: -1, y: 1)
            } else {
                FaceOval()
                    .foregroundStyle(.bgComponentPrimary)
            }
            VStack(spacing: 20) {
                topHint.padding(.top, 50)
                Spacer()
                if !tip.isEmpty {
                    bottomHint
                }
                if isPictureTaken {
                    HStack(spacing: 12) {
                        retakeButton
                        confirmButton
                    }
                } else {
                    takeButton
                }
            }
            .padding(.horizontal, 32)
        }
        .onAppear(perform: viewModel.startScanning)
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

    var bottomHint: some View {
        Text("Tip: \(tip)")
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
        viewModel.pauseScanning()
    }

    func retakePicture() {
        FeedbackGenerator.shared.impact(.medium)
        isPictureTaken = false
        viewModel.startScanning()
    }

    func confirmPicture() {
        FeedbackGenerator.shared.impact(.medium)
        Task { @MainActor in
            isSubmitting = true
            // TODO: process and submit the image
            try await Task.sleep(nanoseconds: 3_000_000_000)
            isSubmitting = false

            // TODO: Replace with actual result from image processing
            let isSuccess = Bool.random() // Simulate a result
            if isSuccess {
                FeedbackGenerator.shared.notify(.success)
            } else {
                FeedbackGenerator.shared.notify(.error)
            }

            onSubmit(isSuccess)
        }
    }
}

#Preview {
    PrizeScanScanningView(onSubmit: { _ in })
        .environmentObject(PrizeScanViewModel())
        .environmentObject(PrizeScanCameraViewModel())
}
