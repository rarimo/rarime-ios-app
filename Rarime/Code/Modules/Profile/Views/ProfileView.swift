import SwiftUI

private enum ProfileRoute: Hashable {
    case authMethod, exportKeys, language, theme
}

struct ProfileView: View {
    @EnvironmentObject private var configManager: ConfigManager
    @EnvironmentObject private var settingsManager: SettingsManager
    @EnvironmentObject private var passportManager: PassportManager
    @EnvironmentObject private var userManager: UserManager

    @State private var path: [ProfileRoute] = []

    @State private var isPrivacySheetPresented = false
    @State private var isTermsSheetPresented = false

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
                }
            }
        }
    }

    var content: some View {
        MainViewLayout {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile").subtitle2()
                VStack(spacing: 12) {
                    CardContainer {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(passportManager.passport?.fullName ?? String(localized: "Account"))
                                    .subtitle3()
                                    .foregroundStyle(.textPrimary)
                                Text(userManager.userAddress)
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
                                action: { path.append(.language) }
                            )
                            ProfileRow(
                                icon: Icons.sun,
                                title: String(localized: "Theme"),
                                value: settingsManager.colorScheme.title,
                                action: { path.append(.theme) }
                            )
                            ProfileRow(
                                icon: Icons.question,
                                title: String(localized: "Privacy Policy"),
                                action: { isPrivacySheetPresented = true }
                            )
                            .fullScreenCover(isPresented: $isPrivacySheetPresented) {
                                SafariWebView(url: configManager.privacyPolicyURL)
                                    .ignoresSafeArea()
                            }
                            ProfileRow(
                                icon: Icons.flag,
                                title: String(localized: "Terms of Use"),
                                action: { isTermsSheetPresented = true }
                            )
                            .fullScreenCover(isPresented: $isTermsSheetPresented) {
                                SafariWebView(url: configManager.termsOfUseURL)
                                    .ignoresSafeArea()
                            }
                        }
                    }
                    Text("App version: \(configManager.version)")
                        .body4()
                        .foregroundStyle(.textDisabled)
                }
                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(.backgroundPrimary)
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
        .environmentObject(MainView.ViewModel())
        .environmentObject(ConfigManager())
        .environmentObject(SettingsManager())
        .environmentObject(PassportManager())
        .environmentObject(SecurityManager())
        .environmentObject(userManager)
        .onAppear {
            _ = try? userManager.createNewUser()
        }
}
