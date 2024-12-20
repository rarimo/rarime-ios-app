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
            BiometryRecoveryFaceView {
                onNext()

                AlertManager.shared.emitSuccess("Access restored successfully")
            }
        }
        .background(.backgroundPure)
        .environmentObject(viewModel)
        .onDisappear {
            viewModel.recoveryTask?.cancel()
        }
    }
}

#Preview {
    BiometryRecoveryView(onNext: {}, onBack: {})
}
