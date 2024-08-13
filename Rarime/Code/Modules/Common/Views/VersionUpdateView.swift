import SwiftUI

struct VersionUpdateView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(Images.gears)
                .resizable()
                .scaledToFit()
                .frame(height: 136)
            VStack(spacing: 8) {
                Text("Update app")
                    .subtitle1()
                    .foregroundStyle(.textPrimary)
                Text("To continue, please install the latest version of the app")
                    .body3()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 250)
            AppButton(
                text: "Open App Store",
                width: nil,
                action: {
                    if let url = URL(string: "itms-appss://apps.apple.com/app/id6503300598") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            )
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.backgroundPure)
    }
}

#Preview {
    VersionUpdateView()
}
