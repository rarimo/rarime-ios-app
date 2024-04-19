import SwiftUI

struct AppSkeleton: View {
    var cornerRadius: CGFloat = 100

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.componentPrimary)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        AppSkeleton().frame(width: 60, height: 12)
        HStack {
            AppSkeleton().frame(width: 140, height: 30)
            Spacer()
            AppSkeleton().frame(width: 60, height: 20)
        }
        AppSkeleton().frame(width: 200, height: 12)
        AppSkeleton().frame(maxWidth: .infinity, maxHeight: 40)
    }
    .padding(20)
}
