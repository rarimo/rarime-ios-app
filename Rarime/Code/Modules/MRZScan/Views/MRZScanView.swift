import SwiftUI

struct MRZScanView: View {
    @StateObject var viewModel = ViewModel()

    var onMrzKey: (String) -> Void

    var body: some View {
        VStack {
            if let image = viewModel.currentFrame {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .clipped()
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background(.black)
        .onAppear {
            viewModel.onMRZKey = onMrzKey
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

#Preview {
    MRZScanView { _ in }
        .frame(height: 300)
}
