import SwiftUI

enum PassportCardLook: Int, CaseIterable {
    case green, black, white

    var name: LocalizedStringResource {
        switch self {
        case .green: return "Green"
        case .black: return "Black"
        case .white: return "White"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .green: return .primaryMain
        case .black: return .baseBlack
        case .white: return .baseWhite
        }
    }

    var foregroundColor: Color {
        switch self {
        case .green: return .baseBlack
        case .black: return .baseWhite
        case .white: return .baseBlack
        }
    }
}

struct PassportCard: View {
    let passport: Passport
    @Binding var look: PassportCardLook
    @Binding var isIncognito: Bool

    var onDelete: () -> Void

    @State private var isSettingsSheetPresented = false
    @State private var isDeleteConfirmationShown = false
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
                    title: String(localized: "Nationality"),
                    value: isInfoHidden ? String("•••") : passport.nationality
                )
                makePassportInfoRow(
                    title: String(localized: "Document #"),
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
            HorizontalDivider()
            Button(action: { isDeleteConfirmationShown = true }) {
                HStack(spacing: 16) {
                    Image(Icons.trashSimple)
                        .iconMedium()
                        .padding(10)
                        .background(.errorLighter)
                        .foregroundStyle(.errorMain)
                        .clipShape(Circle())
                    Text("Delete Card")
                        .buttonMedium()
                        .foregroundStyle(.textPrimary)
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .alert(
            "Delete passport card?",
            isPresented: $isDeleteConfirmationShown,
            actions: {
                Button("Delete", role: .destructive) { onDelete() }
                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text("You will have to scan the passport again to restore it.")
            }
        )
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
            isIncognito: $isIncognito,
            onDelete: {}
        )
    }
}

#Preview {
    PreviewView()
}
