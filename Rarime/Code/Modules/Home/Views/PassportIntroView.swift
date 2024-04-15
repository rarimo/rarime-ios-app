import SwiftUI

struct PassportIntroView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 80) {
                Image("Passport")
                    .resizable()
                    .frame(width: 250, height: 152)
                VStack(alignment: .leading, spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Passport")
                            .h4()
                            .foregroundStyle(.textPrimary)
                        Text("You'll need a biometric document")
                            .body3()
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    HorizontalDivider()
                    VStack(alignment: .leading, spacing: 12) {
                        makeListItem("1.", "Personal data never leaves the device")
                        makeListItem("2.", "Convert your data into ZK proofs")
                        makeListItem("3.", "Use proofs across the ecosystem")
                        makeListItem("🎁", "Get rewarded with 50 RRMO")
                    }
                }
            }
            Spacer()
            HorizontalDivider()
                .padding(.horizontal, -20)
            AppButton(text: "Let's Start", action: onStart)
                .controlSize(.large)
        }
        .padding(.top, 40)
    }

    private func makeListItem(_ number: String, _ text: LocalizedStringResource) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .subtitle4()
                .frame(width: 18)
            Text(text).body3()
        }
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    ZStack {
        PassportIntroView(onStart: {})
    }
    .padding(20)
}
