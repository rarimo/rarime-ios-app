import SwiftUI

struct PassportIntroView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Other passport holders"),
                description: nil,
                icon: Image(Icons.globeSimple).iconLarge()
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Upcoming airdrops will include citizens from all over the world.\n\nCreate an incognito profile by scanning your passport, and we will notify you when you become eligible.")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
            }
            Spacer()
            AppButton(text: "Join the waitlist", rightIcon: Icons.arrowRight, action: onStart)
                .controlSize(.large)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    PassportIntroView(onStart: {})
}
