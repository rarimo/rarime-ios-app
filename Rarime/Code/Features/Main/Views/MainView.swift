//
//  MainView.swift
//  Rarime
//
//  Created by Ivan Lele on 21.03.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Image(Icons.rarime)
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.textPrimary)
            Text("Rarime")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.textPrimary)
        }
            
    }
}

#Preview {
    MainView()
}
