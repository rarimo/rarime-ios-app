//
//  CardContainerView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct CardContainerView<Content: View>: View {
    var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(.backgroundOpacity)
            .cornerRadius(24)
    }
}

#Preview {
    VStack {
        CardContainerView {
            VStack(alignment: .leading, spacing: 4) {
                Text("Wallet").subtitle2()
                Text("Manage your assets").body3()
            }
        }
    }
    .frame(height: 300)
    .background(.backgroundPrimary)
}
