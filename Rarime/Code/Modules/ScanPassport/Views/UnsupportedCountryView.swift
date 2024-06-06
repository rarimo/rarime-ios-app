import SwiftUI

struct UnsupportedCountryView: View {
    @EnvironmentObject var passportViewModel: PassportViewModel

    let onCreate: () -> Void
    let onCancel: () -> Void

    var country: Country {
        passportViewModel.passportCountry
    }

    var body: some View {
        VStack(spacing: 16) {
            HomeIntroLayout(
                title: String(localized: "Unsupported country"),
                description: country.name,
                icon: Text(country.flag)
                    .h4()
                    .frame(width: 72, height: 72)
                    .background(.componentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
            ) {
                Text("Unfortunately, these passports are not eligible for rewards. However, you can use your incognito ID for other upcoming mini apps.")
                    .body3()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            VStack(spacing: 12) {
                AppButton(text: "Create Incognito ID", rightIcon: Icons.arrowRight, action: onCreate)
                    .controlSize(.large)
                AppButton(variant: .tertiary, text: "Cancel", action: onCancel)
                    .controlSize(.large)
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 24)
    }
}

#Preview {
    UnsupportedCountryView(onCreate: {}, onCancel: {})
        .environmentObject(PassportViewModel())
}
