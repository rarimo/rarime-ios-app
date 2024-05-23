import SwiftUI

struct InfoAlert<Content: View>: View {
    var text: LocalizedStringResource
    @ViewBuilder var actionButton: () -> Content

    var body: some View {
        HStack(spacing: 8) {
            Image(Icons.info).iconMedium()
            Text(text).body4()
            Spacer()
            actionButton()
        }
        .padding(8)
        .foregroundColor(.warningDarker)
        .background(.warningLighter)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    VStack(spacing: 16) {
        InfoAlert(text: LocalizedStringResource("This is a warning message", table: "preview")) {}
        InfoAlert(text: LocalizedStringResource("This is a warning message with an action button on the right", table: "preview")) {
            Button(action: {}) {
                Image(Icons.caretRight).iconMedium()
            }
        }
    }
    .padding(16)
}
