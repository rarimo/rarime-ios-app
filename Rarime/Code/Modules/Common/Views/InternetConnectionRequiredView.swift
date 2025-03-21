import SwiftUI

struct InternetConnectionRequiredView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(Icons.globeSimpleX)
                .iconLarge()
                .padding(24)
                .background(.errorLighter, in: Circle())
                .foregroundStyle(.errorMain)
            VStack(spacing: 16) {
                Text("No internet connection")
                    .h3()
                    .foregroundStyle(.textPrimary)
                Text("Your internet connection is down")
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgPrimary)
    }
}

#Preview {
    InternetConnectionRequiredView()
}
