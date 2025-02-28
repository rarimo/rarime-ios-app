import SwiftUI

private enum IdentityRoute: Hashable {
    case scanPassport
}

struct IdentityView: View {
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [IdentityRoute] = []
    @State private var isLivenessSheetPresented = false
    @State private var isSelectTypeSheetPresented = false

    //    TODO: implement claiming tokens
    //    var canReserveTokens: Bool {
    //        !(pointsBalance?.isVerified ?? false)
    //            && !passportManager.isUnsupportedForRewards
    //            && userManager.registerZkProof != nil
    //            && !userManager.isRevoked
    //            && userManager.user?.userReferralCode != nil
    //    }

    private var hasDocument: Bool {
        passportManager.passport != nil
    }

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: IdentityRoute.self) { route in
                switch route {
                case .scanPassport:
                    ScanPassportView(
                        onComplete: { passport in
                            userManager.user?.status = .passportScanned
                            passportManager.setPassport(passport)
                            path.removeLast()
                        },
                        onClose: { path.removeLast() }
                    )
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }

    private var content: some View {
        V2MainViewLayout {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if hasDocument {
                        HStack(alignment: .center, spacing: 8) {
                            Text("You")
                                .subtitle4()
                                .foregroundStyle(.textPrimary)
                            Spacer()
                            AppIconButton(icon: Icons.addFill, action: {
                                isSelectTypeSheetPresented = true
                            })
                            .dynamicSheet(isPresented: $isSelectTypeSheetPresented, fullScreen: true) {
                                SelectIdentityTypeView { identityTypeId in
                                    isSelectTypeSheetPresented = false
                                    selectIdentityType(identityTypeId)
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        VStack {
                            if let passport = passportManager.passport {
                                PassportCard(
                                    passport: passport,
                                    isWaitlist: userManager.registerZkProof == nil,
                                    look: Binding(
                                        get: { passportManager.passportCardLook },
                                        set: { passportManager.setPassportCardLook($0) }
                                    ),
                                    isIncognito: Binding(
                                        get: { passportManager.isIncognitoMode },
                                        set: { passportManager.setIncognitoMode($0) }
                                    ),
                                    identifiers: Binding(
                                        get: { passportManager.passportIdentifiers },
                                        set: { passportManager.setPassportIdentifiers($0) }
                                    )
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        Spacer()
                    } else {
                        SelectIdentityTypeView(onSelect: selectIdentityType)
                    }
                }
            }
        }
        .background(.bgPrimary)
        .dynamicSheet(isPresented: $isLivenessSheetPresented, fullScreen: true) {
            ZkLivenessIntroView(onStart: {
                isLivenessSheetPresented = false
            })
        }
    }

    private func selectIdentityType(_ identityTypeId: IdentityTypeId) {
        switch identityTypeId {
        case .passport:
            path.append(.scanPassport)
        case .zkLiveness:
            isLivenessSheetPresented = true
        default:
            break
        }
    }
}

#Preview {
    IdentityView()
        .environmentObject(V2MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(UserManager())
}
