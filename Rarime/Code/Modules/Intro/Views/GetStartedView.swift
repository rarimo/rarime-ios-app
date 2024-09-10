import Foundation
import SwiftUI

struct GetStartedView: View {
    let onCreate: () -> Void
    let onImport: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Get Started").h5().foregroundStyle(.textPrimary)
                Text("Select an authorization method").body2().foregroundStyle(.textSecondary)
            }
            VStack(spacing: 16) {
                GetStartedButton(
                    title: "Create a new identity",
                    text: "Generates new keys",
                    icon: Icons.userPlus,
                    action: onCreate
                )
                GetStartedButton(
                    title: "Re-activate old profile",
                    text: "Uses pregenerated keys or iClould",
                    icon: Icons.share1,
                    action: onImport
                )
            }
        }
        .padding(.top, 32)
        .padding(.horizontal, 20)
    }
}

private struct GetStartedButton: View {
    let title: LocalizedStringResource
    let text: LocalizedStringResource
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack {
                    Image(icon).iconMedium().foregroundStyle(.textPrimary)
                }
                .padding(10)
                .background(.backgroundOpacity)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).buttonMedium().foregroundStyle(.textPrimary)
                    Text(text).body4().foregroundStyle(.textSecondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(.componentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    GetStartedView(
        onCreate: {},
        onImport: {}
    )
}
