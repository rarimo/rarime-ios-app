import SwiftUI

struct BiometryRecoveryProcessingView: View {
    @EnvironmentObject private var viewModel: BiometryRecoveryView.ViewModel

    let image: UIImage

    var body: some View {
        VStack {
            Spacer()
        }
    }
}

#Preview {
    BiometryRecoveryProcessingView(image: UIImage(resource: .USDC))
        .environmentObject(BiometryRecoveryView.ViewModel())
}
