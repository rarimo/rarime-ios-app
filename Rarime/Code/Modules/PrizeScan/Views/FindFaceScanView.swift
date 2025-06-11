import SwiftUI

private enum ScanState {
    case scanning, failed, success
}

struct HiddenKeysScanView: View {
    @EnvironmentObject private var hiddenKeysViewModel: HiddenKeysViewModel

    let onClose: () -> Void
    let onViewWallet: () -> Void

    @StateObject var viewModel = HiddenKeysCameraViewModel()
    @State private var scanState: ScanState = .scanning

    var body: some View {
        CameraPermissionView(onCancel: onClose) {
            ZStack {
                blurredFace
                mainContent
                if scanState != .success {
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
                    HiddenKeysScanningView(onSubmit: { result in
                        scanState = result ? .success : .failed
                    })
                    .environmentObject(viewModel)
                    .environmentObject(hiddenKeysViewModel)
                case .failed:
                    HiddenKeysFailedView(onScanAgain: {
                        scanState = .scanning
                    })
                    .environmentObject(hiddenKeysViewModel)
                case .success:
                    HiddenKeysSuccessView(onViewWallet: {
                        cleanup()
                        onViewWallet()
                    })
                    .environmentObject(hiddenKeysViewModel)
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
            HiddenKeysScanView(onClose: {}, onViewWallet: {})
                .environmentObject(HiddenKeysViewModel())
        }
}
