import SwiftUI

struct ScanPassportLayoutView<Content: View>: View {
    let title: LocalizedStringResource
    let onPrevious: () -> Void
    let onClose: () -> Void
    
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 38) {
                HStack(alignment: .center) {
                    AppIconButton(icon: Icons.arrowLeftSLine, action: onPrevious)
                    Spacer()
                    AppIconButton(icon: Icons.closeFill, action: onClose)
                }
                Text(title)
                    .h2()
                    .foregroundStyle(.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 20)
    }
}

#Preview {
    ScanPassportLayoutView(
        title: LocalizedStringResource("Scan your Passport", table: "preview"),
        onPrevious: {},
        onClose: {}
    ) {
        Rectangle()
            .fill(.black)
            .frame(height: 300)
        Spacer()
    }
}
