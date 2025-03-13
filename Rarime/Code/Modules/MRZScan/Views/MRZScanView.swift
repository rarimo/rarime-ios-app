import SwiftUI

struct MRZScanView: View {
    @EnvironmentObject private var passportViewModel: PassportViewModel
    @StateObject var viewModel = ViewModel()

    var onMrzKey: (String) -> Void

    var body: some View {
        VStack {
            if let image = viewModel.currentFrame {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 305)
                    .clipped()
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 305)
        .background(.black)
        .onAppear {
            viewModel.onUSA = { self.passportViewModel.isUSA = true }
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
        .environmentObject(PassportViewModel())
}
