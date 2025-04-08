import SwiftUI

struct EnableLayoutView: View {
    let icon: String
    let title: String
    let description: String
    let enableAction: () -> Void
    let skipAction: () -> Void

    var body: some View {
        VStack {
            VStack {
                Image(icon)
                    .square(72)
                    .foregroundStyle(.primaryDarker)
            }
            .padding(40)
            .background(.primaryLighter)
            .clipShape(Circle())
            VStack(spacing: 12) {
                Text(title)
                    .h2()
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                Text(description)
                    .body4()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.vertical, 64)
            Spacer()
            VStack(spacing: 8) {
                AppButton(text: "Enable", action: enableAction)
                    .controlSize(.large)
                AppButton(
                    variant: .quartenary,
                    text: "Maybe Later",
                    action: skipAction
                )
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 72)
        .padding(.bottom, 16)
        .background(.bgPure)
    }
}

#Preview {
    EnableLayoutView(
        icon: Icons.password,
        title: "Enable\nPasscode",
        description: "Enable Passcode Authentication",
        enableAction: {},
        skipAction: {}
    )
}
