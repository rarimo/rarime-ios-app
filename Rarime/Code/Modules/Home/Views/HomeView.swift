//
//  HomeView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct HomeView: View {
    let onBalanceTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(spacing: 8) {
                HStack {
                    Button(action: onBalanceTap) {
                        HStack(spacing: 4) {
                            Text("Balance: RMO").body3()
                            Image(Icons.caretRight).iconSmall()
                        }
                    }
                    .foregroundStyle(.textSecondary)
                    Spacer()
                    Button(action: {}) {
                        Image(Icons.qrCode).iconMedium()
                    }
                }

                HStack {
                    Text("0").h4().foregroundStyle(.textPrimary)
                    Spacer()
                    ZStack {
                        Text("Beta launch")
                            .body3()
                            .foregroundStyle(.warningDark)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(.warningLighter)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 8)

            VStack(spacing: 24) {
                CardContainer {
                    VStack(spacing: 20) {
                        ZStack {
                            Text("🇺🇦").h4()
                        }
                        .frame(width: 72, height: 72)
                        .background(.componentPrimary)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        VStack(spacing: 8) {
                            Text("Programable Airdrop")
                                .h6()
                                .foregroundStyle(.textPrimary)
                            Text("Beta launch is focused on distributing tokens to Ukrainian identity holders")
                                .body2()
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.textSecondary)
                        }
                        HorizontalDivider()
                        AppButton(text: "Let’s Start", rightIcon: Icons.arrowRight) {}
                            .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                }
                Button(action: {}) {
                    CardContainer {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Other passport holders")
                                    .subtitle3()
                                    .foregroundStyle(.textPrimary)
                                Text("Join a waitlist")
                                    .body3()
                                    .foregroundStyle(.textSecondary)
                            }
                            Spacer()
                            ZStack {
                                Image(Icons.caretRight)
                                    .iconSmall()
                            }
                            .padding(4)
                            .background(.primaryMain)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            .foregroundStyle(.textPrimary)
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 32)
        .background(.backgroundPrimary)
    }
}

#Preview {
    HomeView(onBalanceTap: {})
}
