import SwiftUI

struct BiometryRecoverySuccessView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack {
            if isAnimating {
                Image(systemName: "checkmark")
                    .resizable()
                    .animation(.smooth)
                    .foregroundStyle(.backgroundPure)
                    .frame(width: 125, height: 125)
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

                withAnimation {
                    isAnimating = false
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Circle()
            .foregroundStyle(.primaryMain)
        BiometryRecoverySuccessView()
    }
    .frame(width: 300, height: 300)
}
