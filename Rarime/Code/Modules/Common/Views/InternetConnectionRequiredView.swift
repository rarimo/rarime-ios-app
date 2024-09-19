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
                    .h5()
                    .foregroundStyle(.textPrimary)
                Text("Your internet connection is down")
                    .body3()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPrimary)
    }
}

#Preview {
    InternetConnectionRequiredView()
}
