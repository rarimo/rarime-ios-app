import SwiftUI

struct ProcessingChipView: View {
    let status: ProcessingStatus

    var body: some View {
        HStack {
            if let icon = status.icon {
                Image(icon).iconSmall()
            }
            Text(status.text).overline3()
        }
        .frame(height: 24)
        .fixedSize(horizontal: true, vertical: false)
        .frame(minWidth: status.isDownloading ? 90 : nil, alignment: .center)
        .padding(.horizontal, 8)
        .background(status.backgroundColor)
        .clipShape(Capsule())
        .foregroundStyle(status.foregroundColor)
        .animation(.easeInOut, value: status)
    }
}

#Preview {
    VStack {
        ProcessingChipView(status: .downloading("10.1/20.2 MB"))
        ProcessingChipView(status: .processing)
        ProcessingChipView(status: .success)
        ProcessingChipView(status: .failure)
    }
}
