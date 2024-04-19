import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel

    var body: some View {
        MainViewLayout {
            VStack(alignment: .leading, spacing: 20) {
                Text("Profile").subtitle2()
                VStack(spacing: 12) {
                    CardContainer {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Account")
                                    .subtitle3()
                                    .foregroundStyle(.textPrimary)
                                Text("DID: Didq234234rw3423")
                                    .body4()
                                    .foregroundStyle(.textSecondary)
                            }
                            Spacer()
                            PassportImageView(image: nil, size: 40)
                        }
                    }
                    CardContainer {
                        VStack(spacing: 20) {
                            ProfileRow(
                                icon: Icons.userFocus,
                                title: String(localized: "Auth Method"),
                                action: {}
                            )
                            ProfileRow(
                                icon: Icons.key,
                                title: String(localized: "Export Keys"),
                                action: {}
                            )
                        }
                    }
                    CardContainer {
                        VStack(spacing: 20) {
                            ProfileRow(
                                icon: Icons.globeSimple,
                                title: String(localized: "Language"),
                                value: "English",
                                action: {}
                            )
                            ProfileRow(
                                icon: Icons.sun,
                                title: String(localized: "Theme"),
                                value: "Light",
                                action: {}
                            )
                            ProfileRow(
                                icon: Icons.question,
                                title: String(localized: "Privacy Policy"),
                                action: {}
                            )
                            ProfileRow(
                                icon: Icons.flag,
                                title: String(localized: "Terms of Use"),
                                action: {}
                            )
                        }
                    }
                    Text("App version: 1.0")
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

#Preview {
    ProfileView()
        .environmentObject(AppView.ViewModel())
        .environmentObject(MainView.ViewModel())
}
