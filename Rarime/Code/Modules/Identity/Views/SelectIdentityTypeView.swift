import SwiftUI

private struct IdentityType: Identifiable, Hashable {
    var id: IdentityTypeId
    var name: String
    var icon: String
    var isAvailable: Bool
    var isHidden: Bool = false
}

struct SelectIdentityTypeView: View {
    @EnvironmentObject private var passportManager: PassportManager

    let onSelect: (IdentityTypeId) -> Void
    let onClose: (() -> Void)?
    
    init(onSelect: @escaping (IdentityTypeId) -> Void, onClose: (() -> Void)? = nil) {
        self.onSelect = onSelect
        self.onClose = onClose
    }

    private var identityTypes: [IdentityType] {
        [
            IdentityType(
                id: .passport,
                name: String(localized: "Passport"),
                icon: Icons.passportFill,
                isAvailable: true,
                isHidden: passportManager.passport != nil
            ),
            IdentityType(
                id: .zkLiveness,
                name: String(localized: "ZK Liveness (PoH Killer)"),
                icon: Icons.userFocus,
                isAvailable: true
            ),
            IdentityType(
                id: .idCard,
                name: String(localized: "ID Card"),
                icon: Icons.identificationCard,
                isAvailable: false
            ),
            IdentityType(
                id: .xVerifiedBadge,
                name: String(localized: "X Verified Badge"),
                icon: Icons.sealCheck,
                isAvailable: false
            ),
            IdentityType(
                id: .proofOfEmployment,
                name: String(localized: "Proof of Employment"),
                icon: Icons.suitcaseSimple,
                isAvailable: false
            )
        ].filter { !$0.isHidden }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .foregroundStyle(Gradients.gradientSixth)
                .frame(width: 400, height: 394)
                .offset(x: 200, y: -200)
                .opacity(0.4)
                .blur(radius: 100)
            if let onClose = onClose {
                AppIconButton(icon: Icons.closeFill, action: onClose)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.top, .trailing], 20)
            }
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your")
                        .h1()
                        .foregroundStyle(.textPrimary)
                    Text("ZK Identity")
                        .additional1()
                        .foregroundStyle(Gradients.gradientSixth)
                }
                .padding(.top, 60)
                .padding(.bottom, 72)
                Text("Select identity type")
                    .body3()
                    .foregroundStyle(.textPrimary)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(identityTypes) { identityType in
                            Button(action: { onSelect(identityType.id) }) {
                                IdentityTypeRow(identityType: identityType)
                            }
                            .disabled(!identityType.isAvailable)
                            if identityType.id != identityTypes.last?.id {
                                HorizontalDivider()
                            }
                        }
                    }
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.bgComponentPrimary, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct IdentityTypeRow: View {
    let identityType: IdentityType

    @ViewBuilder var iconBackground: some View {
        if identityType.isAvailable {
            Gradients.gradientFirst
        } else {
            Color.bgComponentDisabled
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(identityType.icon)
                .iconMedium()
                .padding(10)
                .background(iconBackground)
                .foregroundStyle(identityType.isAvailable ? .baseBlack : .textDisabled)
                .clipShape(Circle())
            Text(identityType.name)
                .buttonLarge()
                .foregroundStyle(identityType.isAvailable ? .textPrimary : .textDisabled)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            if identityType.isAvailable {
                Image(Icons.caretRight)
                    .iconSmall()
                    .foregroundStyle(.textSecondary)
            } else {
                Text("Soon")
                    .overline2()
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

#Preview {
    SelectIdentityTypeView { _ in }
        .environmentObject(PassportManager())
}
