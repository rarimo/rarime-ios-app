import SwiftUI

struct IdentityView: View {
    @EnvironmentObject private var passportViewModel: PassportViewModel
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager

    @State private var isSelectTypeSheetPresented = false
    
    @State private var isLivenessSheetPresented = false
    @State private var isScanDocumentSheetPresented = false

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
        content
            .dynamicSheet(isPresented: $isSelectTypeSheetPresented, fullScreen: true) {
                SelectIdentityTypeView { identityTypeId in
                    isSelectTypeSheetPresented = false
                    selectIdentityType(identityTypeId)
                }
            }
            .dynamicSheet(isPresented: $isScanDocumentSheetPresented, fullScreen: true) {
                ScanPassportView(onClose: {
                    isScanDocumentSheetPresented = false
                })
                .environmentObject(passportViewModel)
            }
            .dynamicSheet(isPresented: $isLivenessSheetPresented, fullScreen: true) {
                ZkLivenessIntroView(onStart: {
                    isLivenessSheetPresented = false
                })
            }
            .sheet(isPresented: $passportViewModel.isUserRevoking) {
                PassportRevocationView()
                    .environmentObject(passportViewModel)
                    .interactiveDismissDisabled()
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
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        VStack {
                            if let passport = passportManager.passport {
                                PassportCard(
                                    passport: passport,
                                    isWaitlist:
                                        userManager.registerZkProof == nil &&
                                        userManager.user?.status == .passportScanned,
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
        .environmentObject(passportViewModel)
        .background(.bgPrimary)
    }

    private func selectIdentityType(_ identityTypeId: IdentityTypeId) {
        switch identityTypeId {
        case .passport:
            isScanDocumentSheetPresented = true
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
