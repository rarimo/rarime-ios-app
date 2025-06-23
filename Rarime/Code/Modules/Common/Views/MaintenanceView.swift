import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(.rarime)
                .square(128)
                .foregroundStyle(.textPrimary)
            VStack(spacing: 8) {
                Text("Maintenance in progress")
                    .h3()
                    .foregroundStyle(.textPrimary)
                Text("We're upgrading for a better experience. Back soon!")
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 250)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgPure)
    }
}

#Preview {
    MaintenanceView()
}
