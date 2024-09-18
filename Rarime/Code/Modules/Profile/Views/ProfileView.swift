import MessageUI
import SwiftUI

private enum ProfileRoute: Hashable {
    case authMethod, exportKeys, language, theme, appIcon
}

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    @EnvironmentObject private var configManager: ConfigManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager
    @EnvironmentObject private var appIconManager: AppIconManager
    @EnvironmentObject private var securityManager: SecurityManager
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var decentralizedAuthManager: DecentralizedAuthManager
    @EnvironmentObject private var notificationManager: NotificationManager

    @State private var path: [ProfileRoute] = []

    @State private var isPrivacySheetPresented = false
    @State private var isTermsSheetPresented = false
    @State private var isShareWithDeveloper = false
    @State private var isAccountDeleting = false

    var body: some View {
        NavigationStack(path: $path) {
            content.navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .authMethod:
                    AuthMethodView(onBack: { path.removeLast() })
                case .exportKeys:
                    ExportKeysView(onBack: { path.removeLast() })
                case .language:
                    LanguageView(onBack: { path.removeLast() })
                case .theme:
                    ThemeView(onBack: { path.removeLast() })
                case .appIcon:
                    AppIconView(onBack: { path.removeLast() })
                }
            }
        }
    }

    var content: some View {
        MainViewLayout {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile")
                    .subtitle2()
                    .padding(.horizontal, 8)
                VStack(spacing: 12) {
                    ScrollView {
                        CardContainer {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Account")
                                        .subtitle3()
                                        .foregroundStyle(.textPrimary)
                                    Text("Address: \(RarimoUtils.formatAddress(userManager.userAddress))")
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
                                    icon: Icons.userFocus,
                                    title: String(localized: "Auth Method"),
                                    action: { path.append(.authMethod) }
                                )
                                ProfileRow(
                                    icon: Icons.key,
                                    title: String(localized: "Export Keys"),
                                    action: { path.append(.exportKeys) }
                                )
                            }
                        }
                        CardContainer {
                            VStack(spacing: 20) {
                                ProfileRow(
                                    icon: Icons.globeSimple,
                                    title: String(localized: "Language"),
                                    value: settingsManager.language.title,
                                    action: {
                                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                    }
                                )
                                ProfileRow(
                                    icon: Icons.sun,
                                    title: String(localized: "Theme"),
                                    value: settingsManager.colorScheme.title,
                                    action: { path.append(.theme) }
                                )
                                if appIconManager.isAppIconsSupported {
                                    ProfileRow(
                                        icon: Icons.rarime,
                                        title: String(localized: "App Icon"),
                                        value: appIconManager.appIcon.title,
                                        action: { path.append(.appIcon) }
                                    )
                                }
                                ProfileRow(
                                    icon: Icons.question,
                                    title: String(localized: "Privacy Policy"),
                                    action: { isPrivacySheetPresented = true }
                                )
                                .fullScreenCover(isPresented: $isPrivacySheetPresented) {
                                    SafariWebView(url: configManager.general.privacyPolicyURL)
                                        .ignoresSafeArea()
                                }
                                ProfileRow(
                                    icon: Icons.flag,
                                    title: String(localized: "Terms of Use"),
                                    action: { isTermsSheetPresented = true }
                                )
                                .fullScreenCover(isPresented: $isTermsSheetPresented) {
                                    SafariWebView(url: configManager.general.termsOfUseURL)
                                        .ignoresSafeArea()
                                }
                                if MFMailComposeViewController.canSendMail() {
                                    ProfileRow(
                                        icon: Icons.chat,
                                        title: "Give us Feedback",
                                        action: { isShareWithDeveloper = true }
                                    )
                                    .fullScreenCover(isPresented: $isShareWithDeveloper) {
                                        FeedbackMailView(isShowing: $isShareWithDeveloper)
                                    }
                                }
                            }
                        }
                        CardContainer {
                            Button(action: { isAccountDeleting = true }) {
                                HStack {
                                    Image(Icons.trashSimple)
                                        .iconMedium()
                                        .padding(6)
                                        .background(.errorLighter, in: Circle())
                                    Text("Delete Account")
                                        .subtitle4()
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.errorMain)
                        }
                    }
                    VStack {
                        Text("App version: \(configManager.general.version)")
                            .body4()
                            .foregroundStyle(.textDisabled)
                        Spacer()
                    }
                    .frame(height: 100)
                }
                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(.backgroundPrimary)
            .alert(
                "Delete your account?",
                isPresented: $isAccountDeleting,
                actions: {
                    Button("No", role: .cancel) {
                        self.isAccountDeleting = false
                    }
                    Button("Yes", role: .destructive) {
                        appViewModel.isIntroFinished = false
                        passportManager.reset()
                        securityManager.reset()
                        userManager.reset()
                        walletManager.reset()
                        decentralizedAuthManager.reset()
                        notificationManager.reset()
                        
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
    let icon: String
    let title: String
    var value: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(icon)
                    .iconMedium()
                    .padding(6)
                    .background(.componentPrimary, in: Circle())
                    .foregroundStyle(.textPrimary)
                Text(title)
                    .subtitle4()
                    .foregroundStyle(.textPrimary)
                Spacer()
                if let value {
                    Text(value)
                        .body3()
                        .foregroundStyle(.textSecondary)
                }
                Image(Icons.caretRight)
                    .iconSmall()
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

#Preview {
    @StateObject var userManager = UserManager.shared

    return ProfileView()
        .environmentObject(AppView.ViewModel())
        .environmentObject(MainView.ViewModel())
        .environmentObject(ConfigManager())
        .environmentObject(SettingsManager())
        .environmentObject(PassportManager())
        .environmentObject(SecurityManager())
        .environmentObject(AppIconManager())
        .environmentObject(WalletManager())
        .environmentObject(DecentralizedAuthManager())
        .environmentObject(NotificationManager())
        .environmentObject(userManager)
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
