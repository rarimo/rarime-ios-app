import SwiftUI

private enum ScanState {
    case scanning, failed, success
}

struct FindFaceScanView: View {
    @EnvironmentObject private var findFaceViewModel: FindFaceViewModel

    let onClose: () -> Void
    let onViewWallet: () -> Void

    @StateObject var viewModel = FindFaceCameraViewModel()
    @State private var scanState: ScanState = .scanning

    var body: some View {
        ZStack {
            blurredFace
            mainContent
            if scanState != .success {
                closeButton
            }
        }
        .background(.baseBlack)
    }

    var mainContent: some View {
        ZStack {
            switch scanState {
                case .scanning:
                    FindFaceScanningView(onSubmit: { result in
                        scanState = result ? .success : .failed
                    })
                    .environmentObject(viewModel)
                    .environmentObject(findFaceViewModel)
                case .failed:
                    FindFaceFailedView(onScanAgain: {
                        scanState = .scanning
                    })
                    .environmentObject(findFaceViewModel)
                case .success:
                    FindFaceSuccessView(onViewWallet: {
                        cleanup()
                        onViewWallet()
                    })
                    .environmentObject(findFaceViewModel)
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
            FindFaceScanView(onClose: {}, onViewWallet: {})
                .environmentObject(FindFaceViewModel())
        }
}
