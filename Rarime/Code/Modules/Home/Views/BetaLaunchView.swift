import SwiftUI

struct BetaLaunchView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: "Beta Launch",
                description: "short description text here",
                icon: Image(Icons.rarime).iconLarge()
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors ")
                        .body3()
                        .foregroundStyle(.textPrimary)
                    Text("Full functional available on: \(Text("July").fontWeight(.semibold))")
                        .body3()
                        .foregroundStyle(.warningMain)
                }
            }
            Spacer()
            AppButton(text: "Okay", action: onClose)
                .controlSize(.large)
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    BetaLaunchView(onClose: {})
}