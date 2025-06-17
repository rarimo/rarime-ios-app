import SwiftUI

struct IdentityView: View {
    @Environment(\.scenePhase) var scenePhase

    @EnvironmentObject private var mainViewModel: MainView.ViewModel
    @EnvironmentObject private var passportViewModel: PassportViewModel

    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager

    @State private var isScanDocumentSheetPresented = false
    @State private var isWaitlistedCountrySheetPresented = false
    @State private var isUnsupportedCountrySheetPresented = false

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
            .dynamicSheet(isPresented: $isScanDocumentSheetPresented, fullScreen: true) {
                ScanPassportView(onClose: {
                    isScanDocumentSheetPresented = false
                })
                .environmentObject(passportViewModel)
            }
            .dynamicSheet(isPresented: $passportViewModel.isUserRevoking, fullScreen: true) {
                PassportRevocationView()
                    .environmentObject(passportViewModel)
                    .interactiveDismissDisabled()
            }
            .dynamicSheet(isPresented: $isWaitlistedCountrySheetPresented, fullScreen: true) {
                WaitlistPassportView(
                    onNext: {
                        userManager.user?.status = .passportScanned
                        isWaitlistedCountrySheetPresented = false
                    },
                    onCancel: { isWaitlistedCountrySheetPresented = false }
                )
            }
            .dynamicSheet(isPresented: $isUnsupportedCountrySheetPresented, fullScreen: true) {
                UnsupportedPassportView(onClose: { isUnsupportedCountrySheetPresented = false })
            }
            .onChange(of: scenePhase) { newPhase in
                if userManager.user?.status == .unscanned
                    && passportViewModel.processingStatus == .processing
                    && newPhase == .background
                {
                    AppUserDefaults.shared.isRegistrationInterrupted = true
                }
            }
            .onAppear {
                if AppUserDefaults.shared.isRegistrationInterrupted {
                    passportViewModel.processingStatus = .failure
                }

                if !hasDocument {
                    isScanDocumentSheetPresented = true
                }
            }
            .onChange(of: isScanDocumentSheetPresented) { newValue in
                Task {
                    // Delay to allow the sheet to dismiss
                    try await Task.sleep(for: .seconds(0.1))
                    if !newValue && passportManager.passport == nil {
                        mainViewModel.selectedTab = .home
                    }
                }
            }
    }

    private var content: some View {
        MainViewLayout {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if hasDocument {
                        HStack(alignment: .center, spacing: 8) {
                            Text("You")
                                .subtitle4()
                                .foregroundStyle(.textPrimary)
                            Spacer()
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        VStack {
                            if let passport = passportManager.passport {
                                PassportCard(
                                    passport: passport,
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
                                    ),
                                    onWaitlisted: { isWaitlistedCountrySheetPresented = true },
                                    onUnsupported: { isUnsupportedCountrySheetPresented = true }
                                )
                            }
                        }
                        .padding(.horizontal, 12)
                        Spacer()
                    }
                }
            }
        }
        .background(.bgPrimary)
    }
}

#Preview {
    IdentityView()
        .environmentObject(MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(UserManager())
        .environmentObject(PassportViewModel())
}
