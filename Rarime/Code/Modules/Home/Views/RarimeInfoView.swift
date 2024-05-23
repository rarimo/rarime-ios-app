import SwiftUI

struct RarimeInfoView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "What is RariMe?"),
                description: nil,
                icon: Image(Icons.rarime).iconLarge()
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    makeListItem(Text("RariMe is a self-custody identity wallet where no personal data ever leaves the device and everything is processed locally."))
                    makeListItem(Text("Prove your eligibility, belonging, identity, and contributions — without ever revealing personal data."))
                    makeListItem(Text("\(Text("Incognito mode").fontWeight(.bold).foregroundColor(.textPrimary)) ensures your history, reputation and actions are not lost, but remain confidential and under your control."))
                }
            }
            Spacer()
            AppButton(text: "Okay", action: onClose)
                .controlSize(.large)
                .padding(.horizontal, 20)
        }
    }

    private func makeListItem(_ text: Text) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(.textSecondary)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            text
                .body2()
                .foregroundStyle(.textSecondary)
        }
    }
}

#Preview {
    RarimeInfoView(onClose: {})
}
