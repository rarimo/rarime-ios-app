import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(.gears)
                .resizable()
                .scaledToFit()
                .frame(height: 136)
            VStack(spacing: 24) {
                Text("Maintenance in progress")
                    .subtitle3()
                    .foregroundStyle(.textPrimary)
                Text("We're upgrading for a better experience. Back soon!")
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 300)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgPure)
    }
}

#Preview {
    MaintenanceView()
}
