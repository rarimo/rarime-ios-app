import SwiftUI

struct FindFaceStatusChip: View {
    let status: GuessCelebrityStatus

    var body: some View {
        HStack(spacing: 8) {
            if status == .completed {
                Text("Next one soon")
                    .subtitle6()
            } else {
                Text("Prize-pool:")
                    .subtitle6()
                Text(verbatim: String(FIND_FACE_ETH_REWARD))
                    .h6()
                Image(.ethereum)
                    .iconSmall()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.bgComponentPrimary, in: Capsule())
        .padding(.bottom, 12)
    }
}

#Preview {
    FindFaceStatusChip(status: .active)
}
