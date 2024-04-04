//
//  RewardsView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

private enum RewardsRoute: Hashable {
    case scanPassport
}

struct RewardsView: View {
    @State private var isPassportSheetPresented = false
    @State private var path: [RewardsRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            rewardsContent
                .navigationDestination(for: RewardsRoute.self) { route in
                    switch route {
                    case .scanPassport:
                        ScanPassportView(onClose: { path.removeLast() })
                            .navigationBarBackButtonHidden()
                    }
                }
        }
    }

    var rewardsContent: some View {
        VStack(spacing: 24) {
            Text("Rewards").subtitle2()
            Button(action: { isPassportSheetPresented = true }) {
                Text("Scan Passport").buttonMedium().frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .dynamicSheet(isPresented: $isPassportSheetPresented, fullScreen: true) {
                PassportIntroView(onStart: {
                    isPassportSheetPresented = false
                    path.append(.scanPassport)
                })
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RewardsView()
}
