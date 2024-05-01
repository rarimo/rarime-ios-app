import SwiftUI

struct PassportCard: View {
    let passport: Passport
    @Binding var look: PassportCardLook
    @Binding var isIncognito: Bool

    @State private var isSettingsSheetPresented = false
    @State private var isHolding = false

    var isInfoHidden: Bool {
        isIncognito && !isHolding
    }

    var body: some View {
        cardContent.dynamicSheet(
            isPresented: $isSettingsSheetPresented,
            title: "Settings"
        ) {
            cardSettings
        }
    }

    private var cardContent: some View {
        return VStack(spacing: 24) {
            HStack(alignment: .top) {
                PassportImageView(
                    image: passport.passportImage,
                    bgColor: look.foregroundColor.opacity(0.05)
                )
                .blur(radius: isInfoHidden ? 12 : 0)
                Spacer()
                HStack(spacing: 16) {
                    Image(isIncognito ? Icons.eyeSlash : Icons.eye)
                        .iconMedium()
                        .padding(8)
                        .background(look.foregroundColor.opacity(0.05))
                        .clipShape(Circle())
                        .onTapGesture { isIncognito.toggle() }
                    Image(Icons.dotsThreeOutline)
                        .iconMedium()
                        .padding(8)
                        .background(look.foregroundColor.opacity(0.05))
                        .clipShape(Circle())
                        .onTapGesture { isSettingsSheetPresented.toggle() }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(isInfoHidden ? String("••••• •••••••") : passport.fullName)
                    .h6()
                Text(isInfoHidden ? String("••• ••••• •••") : String(localized: "\(passport.ageString) Years Old"))
                    .body2()
                    .opacity(0.56)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HorizontalDivider(color: look.foregroundColor.opacity(0.05))
            VStack(spacing: 16) {
                makePassportInfoRow(
                    title: isInfoHidden ? String("•••••••••") : String(localized: "Nationality"),
                    value: isInfoHidden ? String("•••") : passport.nationality
                )
                makePassportInfoRow(
                    title: isInfoHidden ? String("••••••••") : String(localized: "Document"),
                    value: isInfoHidden ? String("••••••••") : passport.documentNumber
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(look.backgroundColor)
        .foregroundStyle(look.foregroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isIncognito, !isHolding {
                        isHolding = true
                        FeedbackGenerator.shared.impact(.light)
                    }
                }
                .onEnded { _ in isHolding = false }
        )
    }

    private func makePassportInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title).body3().opacity(0.56)
            Spacer()
            Text(value).subtitle4()
        }
    }

    private var cardSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CARD VISUAL")
                .overline3()
                .foregroundStyle(.textSecondary)
            HStack(spacing: 16) {
                ForEach(PassportCardLook.allCases, id: \.self) { look in
                    PassportLookOption(
                        look: look,
                        isActive: look == self.look,
                        onLookChange: { self.look = $0 }
                    )
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

private struct PassportLookOption: View {
    let look: PassportCardLook
    let isActive: Bool
    let onLookChange: (PassportCardLook) -> Void

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Circle()
                    .fill(look.foregroundColor.opacity(0.1))
                    .frame(width: 12)
                RoundedRectangle(cornerRadius: 100)
                    .fill(look.foregroundColor.opacity(0.1))
                    .frame(width: 29, height: 5)
                RoundedRectangle(cornerRadius: 100)
                    .fill(look.foregroundColor.opacity(0.1))
                    .frame(width: 19, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(look.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.componentPrimary, lineWidth: 1)
            )
            Text(look.name)
                .buttonMedium()
                .foregroundStyle(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(isActive ? .componentPrimary : .clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.componentPrimary, lineWidth: 1)
        )
        .onTapGesture {
            onLookChange(look)
            FeedbackGenerator.shared.impact(.light)
        }
    }
}

private struct PreviewView: View {
    let passport = Passport(
        firstName: "Joshua",
        lastName: "Smith",
        gender: "M",
        passportImageRaw: nil,
        documentType: "P",
        issuingAuthority: "USA",
        documentNumber: "00AA00000",
        documentExpiryDate: "900314",
        dateOfBirth: "970314",
        nationality: "USA"
    )
    @State private var look: PassportCardLook = .black
    @State private var isIncognito: Bool = false

    var body: some View {
        PassportCard(
            passport: passport,
            look: $look,
            isIncognito: $isIncognito
        )
    }
}

#Preview {
    PreviewView()
}
