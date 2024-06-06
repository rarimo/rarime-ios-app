import SwiftUI

struct PassportCard: View {
    let passport: Passport
    let isWaitlist: Bool
    @Binding var look: PassportCardLook
    @Binding var isIncognito: Bool
    @Binding var identifiers: [PassportIdentifier]

    @State private var isSettingsSheetPresented = false
    @GestureState private var isHolding = false

    var isInfoHidden: Bool {
        isIncognito && !isHolding
    }

    var isUnsupported: Bool {
        UNSUPPORTED_REWARD_COUNTRIES.contains(
            Country.fromISOCode(passport.nationality)
        )
    }

    var isBadgeShown: Bool {
        isWaitlist || isUnsupported
    }

    var body: some View {
        VStack(spacing: isBadgeShown ? -48 : 0) {
            if isBadgeShown {
                passportBadge
            }
            cardContent.dynamicSheet(
                isPresented: $isSettingsSheetPresented,
                title: "Settings"
            ) {
                cardSettings
            }
        }
    }

    private var passportBadge: some View {
        HStack(spacing: 16) {
            if isWaitlist {
                Image(Icons.globeSimpleTime)
                    .square(24)
                    .foregroundStyle(.warningMain)
            } else {
                Image(Icons.globeSimpleX)
                    .square(24)
                    .foregroundStyle(.errorMain)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(isWaitlist ? "Waitlist country" : "Unsupported for rewards")
                    .subtitle5()
                    .foregroundStyle(.textPrimary)
                if isWaitlist {
                    Text("You will be notified once added")
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 60)
        .padding(.horizontal, 20)
        .background(.componentPrimary, in: RoundedRectangle(cornerRadius: 24))
    }

    private var cardContent: some View {
        let fullNameValue = isInfoHidden ? "••••• •••••••" : passport.fullName
        let ageValue = isInfoHidden ? "••• ••••• •••" : String(localized: "\(passport.ageString) years old")

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
                Text(fullNameValue).h6()
                Text(ageValue).body2().opacity(0.56)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HorizontalDivider(color: look.foregroundColor.opacity(0.05))
            VStack(alignment: .leading, spacing: 16) {
                ForEach(identifiers, id: \.self) { identifier in
                    makePassportInfoRow(
                        title: isInfoHidden ? identifier.titleStub : identifier.title,
                        value: isInfoHidden ? identifier.valueStub : identifier.getPassportValue(from: passport)
                    )
                }
            }
            .frame(minHeight: 56, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(look.backgroundColor)
        .foregroundStyle(look.foregroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isHolding) { _, state, _ in
                    state = true
                }
        )
        .onChange(of: isHolding) { isHolding in
            if isHolding && isIncognito {
                FeedbackGenerator.shared.impact(.light)
            }
        }
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
            HorizontalDivider()
            PassportIdentifiersPicker(identifiers: $identifiers)
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

private struct PassportIdentifiersPicker: View {
    @Binding var identifiers: [PassportIdentifier]
    let MAX_IDENTIFIERS = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Data").overline3()
                Text("Shows two identifiers on the card").body4()
            }
            .foregroundStyle(.textSecondary)
            ForEach(PassportIdentifier.allCases, id: \.self) { identifier in
                let isSelected = identifiers.contains(identifier)
                HStack {
                    Text(identifier.title)
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    AppToggle(
                        isOn: .constant(isSelected),
                        onChanged: { _ in
                            let newIdentifiers = isSelected
                                ? identifiers.filter { $0 != identifier }
                                : identifiers + [identifier]
                            identifiers = newIdentifiers.sorted { $0.order < $1.order }
                        }
                    )
                    .disabled(identifiers.count >= MAX_IDENTIFIERS && !isSelected)
                }
            }
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
        nationality: "USA",
        dg1: Data(),
        dg15: Data(),
        sod: Data(),
        signature: Data()
    )
    @State private var look: PassportCardLook = .black
    @State private var isIncognito: Bool = false
    @State private var identifiers: [PassportIdentifier] = [.nationality, .documentId]

    var body: some View {
        PassportCard(
            passport: passport,
            isWaitlist: true,
            look: $look,
            isIncognito: $isIncognito,
            identifiers: $identifiers
        )
    }
}

#Preview {
    PreviewView()
}
