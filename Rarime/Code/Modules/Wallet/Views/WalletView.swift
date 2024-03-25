//
//  WalletView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

struct WalletView: View {
    var body: some View {
        NavigationLink(destination: WalletDetailView()) {
            HStack {
                Text("Open wallet").buttonMedium()
                Image(Icons.arrowRight).iconSmall()
            }
            .foregroundColor(.textPrimary)
        }
    }
}

struct WalletDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(Icons.caretLeft).iconMedium()
                    Text("Back").buttonMedium()
                }
            }
            .padding(.vertical, 8)
            VStack {
                Text("Wallet detail")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    WalletView()
}
