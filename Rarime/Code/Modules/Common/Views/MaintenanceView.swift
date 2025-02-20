import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(Images.gears)
                .resizable()
                .scaledToFit()
                .frame(height: 136)
            VStack(spacing: 24) {
                Text("Maintenance in progress")
                    .subtitle1()
                    .foregroundStyle(.textPrimary)
                Text("We're upgrading for a better experience. Back soon!")
                    .body3()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPure)
    }
}

#Preview {
    MaintenanceView()
}

