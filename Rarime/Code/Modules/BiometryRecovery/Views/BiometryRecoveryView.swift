import SwiftUI

struct BiometryRecoveryView: View {
    @StateObject private var viewModel = ViewModel()

    var onNext: () -> Void
    var onBack: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: onBack) {
                    Image(Icons.caretLeft)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                Spacer()
            }
            .padding()
            BiometryRecoveryFaceView()
        }
        .background(.backgroundPure)
        .environmentObject(viewModel)
    }
}

#Preview {
    BiometryRecoveryView(onNext: {}, onBack: {})
}
