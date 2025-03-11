import SwiftUI

struct PassportCard: View {
    @EnvironmentObject private var passportViewModel: PassportViewModel
    @EnvironmentObject private var userManager: UserManager
    
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
    
    var isDisabled: Bool {
        userManager.user?.status != .passportScanned
    }

    var body: some View {
        VStack(spacing: isBadgeShown ? -48 : 0) {
            if isBadgeShown {
                passportBadgeWrapper
            }
            cardContent.dynamicSheet(
                isPresented: $isSettingsSheetPresented,
                title: "Settings",
                bgColor: .bgSurface1
            ) {
                cardSettings
            }
        }
    }

    private var passportBadgeWrapper: some View {
        HStack(spacing: 16) {
            if isWaitlist {
                Image(Icons.globeSimpleTime)
                    .iconLarge()
                    .foregroundStyle(.warningMain)
            } else {
                Image(Icons.globeSimpleX)
                    .iconLarge()
                    .foregroundStyle(.errorMain)
            }
            Text(isWaitlist ? "Waitlisted country" : "Unsupported for rewards")
                .subtitle6()
                .foregroundStyle(.textPrimary)
            Spacer()
            Image(Icons.informationLine)
                .iconMedium()
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 60)
        .padding(.horizontal, 20)
        .background(.bgComponentPrimary, in: RoundedRectangle(cornerRadius: 24))
    }

    private var cardContent: some View {
        let firstNameValue: String = isInfoHidden ? "•••••" : passport.displayedFirstName
        let lastNameValue = isInfoHidden ? "••••••••••••" : passport.displayedLastName
        let ageValue = isInfoHidden ? "•••••••••" : String(localized: "\(passport.ageString) years old")

        return ZStack(alignment: .topTrailing) {
            if let image = passport.passportImage {
                Image(uiImage: VisionUtils.removeBackground(image))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 164)
                    .offset(x: -24, y: 108)
                    .blur(radius: isInfoHidden ? 24 : 0)
            }
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(firstNameValue)
                        .h2()
                        .foregroundStyle(isDisabled ? .textPlaceholder : .textPrimary)
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
                Group {
                    if userManager.user?.status == .passportScanned {
                        cardIdentityDetails
                    }
                    if passportViewModel.processingStatus == .processing &&
                       userManager.user?.status == .unscanned {
                        cardProofGeneration
                    }
                    if passportViewModel.processingStatus == .failure {
                        cardProofError
                    }
                }
                .transition(.opacity)
            }
            Text("PASSPORT")
                .overline2()
                .foregroundStyle(isDisabled ? .textPlaceholder : .textPrimary)
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(.bgComponentPrimary, in: Capsule())
                .padding(8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 326)
        .padding(8)
        .background(
            Image(look.backgroundImage)
                .resizable()
                .scaledToFill()
                .background(.bgPrimary)
                .grayscale(isDisabled ? 1 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .animation(.easeInOut, value: isDisabled)
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
            Text("Data")
                .overline2()
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
            PassportIdentifiersPicker(identifiers: $identifiers, passport: passport)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    private var cardIdentityDetails: some View {
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
                Image(isIncognito ? .eyeOffLine : .eyeLine)
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
    
    private var cardProofGeneration: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(alignment: .center, spacing: 16) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.bgComponentPrimary)
                            .frame(height: 4)
                        Capsule()
                            .fill(.secondaryMain)
                            .frame(width: geometry.size.width * (passportViewModel.proofState.progress / 100.0),
                                   height: 3)
                            .animation(.easeInOut, value: passportViewModel.proofState.progress)
                    }
                }
                .frame(height: 4)
                Text(passportViewModel.proofState.title)
                    .subtitle6()
                    .foregroundStyle(.textSecondary)
                    .frame(width: 90, alignment: .center)
            }
            Text("Please don’t close application")
                .body5()
                .foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 64)
        .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var cardProofError: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(Icons.informationLine)
                .iconMedium()
                .foregroundStyle(.errorDark)
            VStack(alignment: .leading, spacing: 0) {
                Text("Unknown error")
                    .subtitle6()
                    .foregroundStyle(.errorDark)
                Text("Please try again")
                    .body5()
                    .foregroundStyle(.textSecondary)
            }
            Spacer()
            // TODO: sync with design system
            Button(action: {
                Task {
                    await regenerateProof()
                }
            }) {
                HStack(alignment: .center, spacing: 8) {
                    Image(Icons.restartLine)
                        .iconMedium()
                        .foregroundStyle(.baseWhite)
                    Text("Retry")
                        .buttonMedium()
                        .foregroundStyle(.invertedLight)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(height: 32)
            .background(Capsule().fill(.textPrimary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 64)
        .background(.bgBlur, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func regenerateProof() async {
        do {
            let zkProof = try await passportViewModel.register()

            if passportViewModel.processingStatus != .success { return }

            userManager.registerZkProof = zkProof
            userManager.user?.status = .passportScanned
        } catch {
            LoggerUtil.common.error("error while registering passport: \(error.localizedDescription, privacy: .public)")
            if let error = error as? Errors {
                AlertManager.shared.emitError(error)
                passportViewModel.processingStatus = .failure
                return
            }
        }
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

private let MAX_IDENTIFIERS = 1
private struct PassportIdentifiersPicker: View {
    @Binding var identifiers: [PassportIdentifier]
    
    let passport: Passport
   
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data")
                .overline2()
                .foregroundStyle(.textSecondary)
            ForEach(PassportIdentifier.allCases, id: \.self) { identifier in
                let isSelected = identifiers.contains(identifier)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(identifier.title)
                            .body4()
                            .foregroundStyle(.textSecondary)
                        Text(identifier.getPassportValue(from: passport))
                            .subtitle5()
                            .foregroundStyle(.textPrimary)
                    }
                    Spacer()
                    AppRadioButton(isSelected: isSelected) {
                        identifiers = [identifier]
                    }
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
        .environmentObject(PassportViewModel())
        .environmentObject(UserManager())
}
