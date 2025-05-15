import SwiftUI

private enum ScanState {
    case scanning, failed, success, claiming, finished
}

struct PrizeScanCameraView: View {
    @EnvironmentObject private var prizeScanViewModel: PrizeScanViewModel

    let onClose: () -> Void

    @StateObject var viewModel = PrizeScanCameraViewModel()
    @State private var scanState: ScanState = .scanning

    var body: some View {
        ZStack {
            blurredFace
            mainContent
            closeButton
        }
        .background(.baseBlack)
    }

    var mainContent: some View {
        ZStack {
            switch scanState {
                case .scanning:
                    PrizeScanScanningView(onSubmit: { result in
                        scanState = result ? .success : .failed
                    })
                    .environmentObject(viewModel)
                    .environmentObject(prizeScanViewModel)
                case .failed:
                    PrizeScanFailedView(onScanAgain: {
                        scanState = .scanning
                    })
                    .environmentObject(prizeScanViewModel)
                case .success:
                    PrizeScanSuccessView(onClaim: {
                        scanState = .claiming
                    })
                case .claiming:
                    Text("Claiming")
                case .finished:
                    PrizeScanFinishedView(onViewWallet: {
                        cleanup()
                        onClose()
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
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 76)
                    .scaleEffect(x: -1, y: 1)
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
            PrizeScanCameraView(onClose: {})
        }
}
