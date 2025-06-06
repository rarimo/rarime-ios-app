import SwiftUI

struct ProfileRouteLayout<Content: View>: View {
    let title: String
    let onBack: () -> Void

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ZStack(alignment: .topLeading) {
                Button(action: onBack) {
                    Image(.arrowLeftSLine)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                Text(title)
                    .buttonMedium()
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            content()
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .background(.bgPrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ProfileRouteLayout(
        title: "Profile Route Title",
        onBack: {}
    ) {
        VStack {
            CardContainer {
                Text(String("Profile Route Content"))
            }
        }
    }
}
