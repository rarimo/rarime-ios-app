import SwiftUI

struct CardContainer<Content: View>: View {
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.backgroundOpacity)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    VStack {
        CardContainer {
            VStack(alignment: .leading, spacing: 4) {
                Text(String("Wallet")).subtitle2()
                Text(String("Manage your assets")).body3()
            }
        }
    }
    .frame(height: 300)
    .background(.backgroundPrimary)
}
