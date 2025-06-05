import SwiftUI

struct UnsupportedPassportView: View {
    @EnvironmentObject var passportManager: PassportManager

    let onClose: () -> Void

    var country: Country {
        passportManager.passportCountry
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppIconButton(icon: .closeFill, action: onClose)
                .padding([.top, .trailing], 20)
            VStack(spacing: 28) {
                Text(country.flag)
                    .h2()
                    .frame(width: 88, height: 88)
                    .background(.bgComponentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                VStack(spacing: 8) {
                    Text("Unsupported country")
                        .h3()
                        .foregroundStyle(.textPrimary)
                    Text(country.name)
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                HorizontalDivider()
                Text("Unfortunately, these passports are not eligible for rewards. However, you can use your incognito ID for other upcoming mini apps.")
                    .body4()
                    .foregroundStyle(.textSecondary)
                Spacer()
                AppButton(text: "Close", action: onClose)
                    .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.top, 140)
        }
    }
}

#Preview {
    UnsupportedPassportView(onClose: {})
        .environmentObject(PassportManager())
}
