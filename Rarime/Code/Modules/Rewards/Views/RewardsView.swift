//
//  RewardsView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct RewardsView: View {
    @State private var isPassportSheetPresented = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Rewards").subtitle2()
            Button(action: { isPassportSheetPresented = true }) {
                Text("Scan Passport").buttonMedium().frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .dynamicSheet(isPresented: $isPassportSheetPresented, fullScreen: true) {
                PassportSheetView()
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    RewardsView()
}
