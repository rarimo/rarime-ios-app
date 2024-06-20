import SwiftUI

struct RarimeInfoView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "What is RariMe?"),
                icon: Image(Icons.rarime)
                    .iconLarge()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    makeListItem(Text("RariMe is a self-custody identity wallet where no personal data ever leaves the device and everything is processed locally."))
                    makeListItem(Text("With RariMe, identity becomes private but verifiable."))
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
