//
//  HomeView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct HomeView: View {
    @State private var currentSheet: SheetType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("Welcome back!").h5().foregroundStyle(.textPrimary)
                        Spacer()
                        Button {
                            currentSheet = .notifications
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Image(Icons.bellFill).iconMedium()
                        }.foregroundStyle(.textPrimary)
                    }
                    .padding(.top, 16)
                    CardContainerView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dashboard").subtitle2().foregroundStyle(.textPrimary)
                            Text("Overview of your account").body3().foregroundStyle(.textSecondary)
                        }
                    }
                    CardContainerView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Wallet").subtitle2().foregroundStyle(.textPrimary)
                            Text("Manage your assets").body3().foregroundStyle(.textSecondary)
                        }
                    }
                    CardContainerView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rewards").subtitle2().foregroundStyle(.textPrimary)
                            Text("Participate and get rewarded").body3().foregroundStyle(.textSecondary)
                        }
                    }
                    CardContainerView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Credentials").subtitle2().foregroundStyle(.textPrimary)
                            Text("Store your documents securely").body3().foregroundStyle(.textSecondary)
                        }
                    }
                    CardContainerView {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings").subtitle2().foregroundStyle(.textPrimary)
                            Text("Manage your account settings").body3().foregroundStyle(.textSecondary)
                        }
                    }
                    Button {
                        currentSheet = .help
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text("Open sheet").buttonMedium().frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryContainedButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
            }
            .padding(.top, 1)
            .background(.backgroundPrimary)
            .sheet(item: $currentSheet, content: {
                Text("Sheet: \($0.id)")
            })
        }
    }
}

#Preview {
    HomeView()
}
