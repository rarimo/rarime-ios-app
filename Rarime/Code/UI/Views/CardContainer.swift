import SwiftUI

struct CardContainer<Content: View>: View {
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.bgComponentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    VStack {
        CardContainer {
            VStack(alignment: .leading, spacing: 4) {
                Text(String("Wallet")).buttonLarge()
                Text(String("Manage your assets")).body4()
            }
        }
    }
    .frame(height: 300)
    .background(.bgPrimary)
}
