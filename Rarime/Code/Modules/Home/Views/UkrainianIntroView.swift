import SwiftUI

struct UkrainianIntroView: View {
    let onStart: () -> Void
    @State private var termsChecked = false

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Programmable rewards"),
                description: String(localized: "Campaign is focused on distributing rewards to Ukrainian citizens"),
                icon: Text(try! String("🇺🇦"))
                    .h4()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What’s that?")
                        .overline2()
                        .foregroundStyle(.textSecondary)
                    Text("It showcases Rarimo’s identity infrastructure and how it can be used by projects and organizations to directly reach civilians.")
                        .body3()
                        .foregroundStyle(.textPrimary)
                }
            }
            Spacer()
            HorizontalDivider()
            AirdropCheckboxView(checked: $termsChecked)
                .padding(.horizontal, 20)
            AppButton(text: "Continue", action: onStart)
                .controlSize(.large)
                .disabled(!termsChecked)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    UkrainianIntroView(onStart: {})
        .environmentObject(ConfigManager())
}
