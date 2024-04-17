import SwiftUI

struct HorizontalDivider: View {
    var color: Color = .componentPrimary
    var height: CGFloat = 1

    var body: some View {
        color.frame(height: height)
    }
}

struct VerticalDivider: View {
    var color: Color = .componentPrimary
    var width: CGFloat = 1

    var body: some View {
        color.frame(width: width)
    }
}

#Preview {
    VStack(spacing: 24) {
        HorizontalDivider()
        HorizontalDivider(color: .warningDark, height: 2)
        HorizontalDivider(color: .errorDark, height: 3)
        HStack(spacing: 24) {
            VerticalDivider()
            VerticalDivider(color: .warningDark, width: 2)
            VerticalDivider(color: .errorDark, width: 3)
        }
        .frame(height: 48)
    }
    .padding()
}
