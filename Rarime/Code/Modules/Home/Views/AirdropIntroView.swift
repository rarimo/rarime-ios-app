import SwiftUI

struct AirdropIntroView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 32) {
                header
                HorizontalDivider()
                VStack(alignment: .leading, spacing: 12) {
                    makeListItem("1.", "Personal data never leaves the device")
                    makeListItem("2.", "Full privacy via Zero Knowledge Proofs")
                    makeListItem("3.", "Get rewarded with RMO tokens")
                }
                programInfo
            }
            Spacer()
            HorizontalDivider()
                .padding(.horizontal, -20)
            HStack(alignment: .top, spacing: 8) {
                Rectangle()
                    .fill(.backgroundPrimary)
                    .frame(width: 20, height: 20)
                Text("By checking this box, you are agreeing to RariMe General Terms & Conditions, RariMe Privacy Notice  and Rarimo Airdrop Program Terms & Conditions")
                    .body4()
                    .foregroundStyle(.textSecondary)
                Spacer()
            }
            AppButton(text: "Continue", action: onStart)
                .controlSize(.large)
        }
        .padding(.top, 40)
    }

    private var header: some View {
        VStack(spacing: 16) {
            Text("🇺🇦")
                .h4()
                .frame(width: 72, height: 72)
                .background(.componentPrimary)
                .clipShape(Circle())
            Text("Programable Airdrop")
                .h6()
                .foregroundStyle(.textPrimary)
            Text("Beta launch is focused on distributing tokens to Ukrainian identity holders")
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
            Text("What is this?")
                .overline2()
                .foregroundStyle(.textSecondary)
            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it h")
                .body3()
                .foregroundStyle(.textPrimary)
            Text("Full functional avaiable on: \(Text("July").fontWeight(.semibold))")
                .body3()
                .foregroundStyle(.warningMain)
        }
    }

    private func makeListItem(_ number: String, _ text: LocalizedStringResource) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .subtitle4()
                .frame(width: 18)
            Text(text).body3()
        }
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    AirdropIntroView(onStart: {})
        .padding(20)
}
