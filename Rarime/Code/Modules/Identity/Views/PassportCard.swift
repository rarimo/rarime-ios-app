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
        isWaitlist
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
                    .subtitle7()
                    .foregroundStyle(.textPrimary)
                if isWaitlist {
                    Text("You will be notified once added")
                        .body5()
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 60)
        .padding(.horizontal, 20)
        .background(.bgComponentPrimary, in: RoundedRectangle(cornerRadius: 24))
    }

    private var cardContent: some View {
        let firstNameValue = isInfoHidden ? "•••••" : passport.firstName
        let lastNameValue = isInfoHidden ? "•••••••" : passport.lastName
        let ageValue = isInfoHidden ? "••• ••••• •••" : String(localized: "\(passport.ageString) years old")

        return ZStack(alignment: .topTrailing) {
            if let image = passport.passportImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 164)
                    .offset(x: -24, y: 84)
                    .blur(radius: isInfoHidden ? 24 : 0)
            }
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(firstNameValue)
                        .h2()
                        .foregroundStyle(.textPrimary)
                    Text(lastNameValue)
                        .additional2()
                        .foregroundStyle(.textPlaceholder)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.horizontal, 16)
                Text(ageValue)
                    .body3()
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, 16)
                Spacer()
                    .frame(height: 84)
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(identifiers, id: \.self) { identifier in
                            Text(identifier.title)
                                .subtitle6()
                                .foregroundStyle(.textSecondary)
                            Text(isInfoHidden ? identifier.valueStub : identifier.getPassportValue(from: passport))
                                .subtitle5()
                                .foregroundStyle(.textPrimary)
                        }
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        Image(isIncognito ? .eyeSlash : .eye)
                            .iconMedium()
                            .padding(8)
                            .background(.bgComponentPrimary, in: Circle())
                            .foregroundColor(.textSecondary)
                            .onTapGesture { isIncognito.toggle() }
                        Image(.dotsThreeOutline)
                            .iconMedium()
                            .padding(8)
                            .background(.bgComponentPrimary, in: Circle())
                            .foregroundColor(.textSecondary)
                            .onTapGesture { isSettingsSheetPresented.toggle() }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(height: 64)
                .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
            }
            Text("PASSPORT")
                .overline2()
                .foregroundStyle(.textPrimary)
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(.bgComponentPrimary, in: Capsule())
                .padding(8)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            Image(look.backgroundImage)
                .resizable()
                .scaledToFill()
                .background(.bgPrimary)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
                    .fill(.bgComponentHovered)
                    .frame(width: 12)
                RoundedRectangle(cornerRadius: 100)
                    .fill(.bgComponentHovered)
                    .frame(width: 29, height: 5)
                RoundedRectangle(cornerRadius: 100)
                    .fill(.bgComponentHovered)
                    .frame(width: 19, height: 5)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(
                Image(look.backgroundImage)
                    .resizable()
                    .scaledToFill()
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.bgComponentPrimary, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? .textPrimary : .bgComponentPrimary, lineWidth: 1)
        )
        .onTapGesture {
            onLookChange(look)
            FeedbackGenerator.shared.impact(.light)
        }
    }
}

private struct PassportIdentifiersPicker: View {
    @Binding var identifiers: [PassportIdentifier]
    let MAX_IDENTIFIERS = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Data").overline2()
                Text("Shows an identifier on the card").body5()
            }
            .foregroundStyle(.textSecondary)
            ForEach(PassportIdentifier.allCases, id: \.self) { identifier in
                let isSelected = identifiers.contains(identifier)
                HStack {
                    Text(identifier.title)
                        .subtitle6()
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
    @State private var look: PassportCardLook = .holographicViolet
    @State private var isIncognito: Bool = false
    @State private var identifiers: [PassportIdentifier] = [.documentId]

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
