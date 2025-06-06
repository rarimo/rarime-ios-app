import MessageUI
import SwiftUI

private enum ProfileRoute: Hashable {
    case authMethod, exportKeys, theme, appIcon
}

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    @EnvironmentObject private var configManager: ConfigManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var appIconManager: AppIconManager
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var likenessManager: LikenessManager
    @EnvironmentObject private var pollsViewModel: PollsViewModel
    @EnvironmentObject private var walletManager: WalletManager

    @StateObject private var homeWidgetsViewModel = HomeWidgetsViewModel()

    @State private var path: [ProfileRoute] = []

    @State private var isPrivacySheetPresented = false
    @State private var isTermsSheetPresented = false
    @State private var isShareWithDeveloper = false
    @State private var isAccountDeleting = false

    @State private var isDebugOptionsShown = false

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .authMethod:
                    AuthMethodView(onBack: { path.removeLast() })
                        .navigationBarBackButtonHidden()
                case .exportKeys:
                    ExportKeysView(onBack: { path.removeLast() })
                        .navigationBarBackButtonHidden()
                case .theme:
                    ThemeView(onBack: { path.removeLast() })
                        .navigationBarBackButtonHidden()
                case .appIcon:
                    AppIconView(onBack: { path.removeLast() })
                        .navigationBarBackButtonHidden()
                }
            }
        }
#if DEVELOPMENT
        .sheet(isPresented: $isDebugOptionsShown, content: DebugOptionsView.init)
#endif
    }

    var content: some View {
        MainViewLayout {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile")
                    .subtitle4()
                    .padding(.horizontal, 8)
                VStack(spacing: 12) {
                    ScrollView(showsIndicators: false) {
                        CardContainer {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Account")
                                        .buttonLarge()
                                        .foregroundStyle(.textPrimary)
                                    Text(verbatim: Ethereum.formatAddress(userManager.ethereumAddress ?? ""))
                                        .body4()
                                        .foregroundStyle(.textSecondary)
                                }
                                Spacer()
                                PassportImageView(image: passportManager.passport?.passportImage, size: 40)
                            }
                        }
                        CardContainer {
                            VStack(spacing: 20) {
                                ProfileRow(
                                    icon: .userFocus,
                                    title: String(localized: "Auth Method"),
                                    action: { path.append(.authMethod) }
                                )
                                ProfileRow(
                                    icon: .key,
                                    title: String(localized: "Export Keys"),
                                    action: { path.append(.exportKeys) }
                                )
                            }
                        }
                        CardContainer {
                            VStack(spacing: 20) {
                                ProfileRow(
                                    icon: .sun,
                                    title: String(localized: "Theme"),
                                    value: settingsManager.colorScheme.title,
                                    action: { path.append(.theme) }
                                )
                                if appIconManager.isAppIconsSupported {
                                    ProfileRow(
                                        icon: .rarime,
                                        title: String(localized: "App Icon"),
                                        value: appIconManager.appIcon.title,
                                        action: { path.append(.appIcon) }
                                    )
                                }
                                ProfileRow(
                                    icon: .questionLine,
                                    title: String(localized: "Privacy Policy"),
                                    action: { isPrivacySheetPresented = true }
                                )
                                .fullScreenCover(isPresented: $isPrivacySheetPresented) {
                                    SafariWebView(url: configManager.general.privacyPolicyURL)
                                        .ignoresSafeArea()
                                }
                                ProfileRow(
                                    icon: .flag,
                                    title: String(localized: "Terms of Use"),
                                    action: { isTermsSheetPresented = true }
                                )
                                .fullScreenCover(isPresented: $isTermsSheetPresented) {
                                    SafariWebView(url: configManager.general.termsOfUseURL)
                                        .ignoresSafeArea()
                                }
                                if MFMailComposeViewController.canSendMail() {
                                    ProfileRow(
                                        icon: .chat,
                                        title: "Give us Feedback",
                                        action: { isShareWithDeveloper = true }
                                    )
                                    .fullScreenCover(isPresented: $isShareWithDeveloper) {
                                        FeedbackMailView(isShowing: $isShareWithDeveloper)
                                    }
                                }
                            }
                        }
#if DEVELOPMENT
                        CardContainer {
                            VStack(spacing: 20) {
                                ProfileRow(
                                    icon: .dotsThreeOutline,
                                    title: String(localized: "Debug Options"),
                                    action: {
                                        isDebugOptionsShown = true
                                    }
                                )
                            }
                        }
#endif
                        CardContainer {
                            Button(action: { isAccountDeleting = true }) {
                                HStack {
                                    Image(.trashSimple)
                                        .iconMedium()
                                        .padding(6)
                                        .background(.errorLighter, in: Circle())
                                    Text("Delete Account")
                                        .buttonMedium()
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.errorMain)
                        }
                        Text("App version: \(configManager.general.version)")
                            .body5()
                            .foregroundStyle(.textPlaceholder)
                            .padding(.bottom, 20)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 12)
            .background(.bgPrimary)
            .alert(
                "Delete your account?",
                isPresented: $isAccountDeleting,
                actions: {
                    Button("No", role: .cancel) {
                        self.isAccountDeleting = false
                    }
                    Button("Yes", role: .destructive) {
                        appViewModel.isIntroFinished = false
                        AppUserDefaults.shared.isHomeOnboardingCompleted = false
                        AppUserDefaults.shared.hasPointsBalance = false

                        passportManager.reset()
                        securityManager.reset()
                        userManager.reset()
                        decentralizedAuthManager.reset()
                        notificationManager.reset()
                        pollsViewModel.reset()
                        likenessManager.reset()
                        walletManager.reset()
                        homeWidgetsViewModel.reset()

                        Task {
                            try? await notificationManager.unsubscribe(fromTopic: ConfigManager.shared.general.claimableNotificationTopic)
                        }
                    }
                },
                message: {
                    Text("This action is irreversible and will delete all your data.")
                }
            )
        }
    }
}

private struct ProfileRow: View {
    let icon: ImageResource
    let title: String
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .iconMedium()
                    .padding(6)
                    .background(.bgComponentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                Text(title)
                    .buttonMedium()
                    .foregroundStyle(.textPrimary)
                Spacer()
                if let value {
                    Text(value)
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                Image(.caretRight)
                    .iconMedium()
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

#Preview {
    let userManager = UserManager.shared

    return ProfileView()
        .environmentObject(AppView.ViewModel())
        .environmentObject(MainView.ViewModel())
        .environmentObject(ConfigManager())
        .environmentObject(SettingsManager())
        .environmentObject(PassportManager())
        .environmentObject(SecurityManager())
        .environmentObject(AppIconManager())
        .environmentObject(DecentralizedAuthManager())
        .environmentObject(NotificationManager())
        .environmentObject(LikenessManager())
        .environmentObject(userManager)
        .environmentObject(WalletManager())
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
