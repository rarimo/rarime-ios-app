import SwiftUI

struct PassportIntroView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 32) {
                header
                HorizontalDivider()
                programInfo
            }
            Spacer()
            AppButton(text: "Join the waitlist", rightIcon: Icons.arrowRight, action: onStart)
                .controlSize(.large)
        }
        .padding(.top, 40)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Text("🌐")
                .h4()
                .frame(width: 72, height: 72)
                .background(.componentPrimary)
                .clipShape(Circle())
            Text("Other passport holders")
                .h6()
                .foregroundStyle(.textPrimary)
            Text("short description text here")
                .body3()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 300)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity/*@END_MENU_TOKEN@*/)
    }

    private var programInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors ")
                .body3()
                .foregroundStyle(.textPrimary)
            Text("Full functional avaiable on: \(Text("July").fontWeight(.semibold))")
                .body3()
                .foregroundStyle(.warningMain)
        }
    }
}

#Preview {
    PassportIntroView(onStart: {})
        .padding(20)
}
