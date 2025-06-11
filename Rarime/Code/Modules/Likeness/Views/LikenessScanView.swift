import SwiftUI

private enum ScanState {
    case scanning, processing, success
}

struct LikenessScanView: View {
    @EnvironmentObject private var likenessManager: LikenessManager

    let onComplete: () -> Void
    let onClose: () -> Void

    @StateObject var viewModel = LikenessFaceViewModel()
    @State private var scanState: ScanState = .scanning

    var body: some View {
        CameraPermissionView(onCancel: onClose) {
            ZStack {
                blurredFace
                mainContent
                if scanState == .scanning {
                    closeButton
                }
            }
            .background(.baseBlack)
        }
    }

    var mainContent: some View {
        ZStack {
            switch scanState {
                case .scanning:
                    LikenessScanningView(
                        onConfirm: { image in
                            likenessManager.setFaceImage(UIImage(cgImage: image))
                            scanState = .processing
                        }
                    )
                    .environmentObject(viewModel)
                case .processing:
                    LikenessProcessingView(
                        onComplete: { scanState = .success },
                        onError: { scanState = .scanning }
                    )
                    .environmentObject(viewModel)
                    .environmentObject(likenessManager)
                case .success:
                    LikenessSuccessView(onClose: {
                        cleanup()
                        onComplete()
                    })
            }
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

    var blurredFace: some View {
        ZStack {
            if let face = viewModel.currentFrame {
                Image(decorative: face, scale: 1)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .blur(radius: 76)
            }
            Color.baseBlack.opacity(0.7)
                .ignoresSafeArea()
        }
    }

    func cleanup() {
        viewModel.stopScanning()
        viewModel.clearImages()
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            LikenessScanView(onComplete: {}, onClose: {})
                .environmentObject(LikenessManager())
        }
}
