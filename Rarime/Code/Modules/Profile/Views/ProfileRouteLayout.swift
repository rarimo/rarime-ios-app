import SwiftUI

struct ProfileRouteLayout<Content: View>: View {
    let title: String
    let onBack: () -> Void

    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ZStack(alignment: .topLeading) {
                Button(action: onBack) {
                    Image(Icons.caretLeft)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                Text(title)
                    .subtitle4()
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
            }
            content()
            Spacer()
        }
        .padding(20)
        .background(.backgroundPrimary)
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
