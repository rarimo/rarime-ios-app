import SwiftUI

struct VersionUpdateView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(.gears)
                .resizable()
                .scaledToFit()
                .frame(height: 136)
            VStack(spacing: 8) {
                Text("Update app")
                    .h3()
                    .foregroundStyle(.textPrimary)
                Text("To continue, please install the latest version of the app")
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 250)
            .multilineTextAlignment(.center)
            AppButton(
                text: "Open App Store",
                width: 160,
                action: {
                    if let url = URL(string: "itms-appss://apps.apple.com/app/id6503300598") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            )
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bgPure)
    }
}

#Preview {
    VersionUpdateView()
}
