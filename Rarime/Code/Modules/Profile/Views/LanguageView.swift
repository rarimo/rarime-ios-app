import SwiftUI

struct LanguageView: View {
    let onBack: () -> Void

    var body: some View {
        ProfileRouteLayout(
            title: String(localized: "Language"),
            onBack: onBack
        ) {
            CardContainer {
                HStack {
                    Text("English").subtitle4()
                    Spacer()
                    Image(Icons.check).iconMedium()
                }
                .foregroundColor(.textPrimary)
            }
        }
    }
}

#Preview {
    LanguageView(onBack: {})
}
