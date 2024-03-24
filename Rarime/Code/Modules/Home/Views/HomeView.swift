//
//  HomeView.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 24.03.2024.
//

import SwiftUI

enum SheetType: Identifiable {
    case help

    var id: String {
        switch self {
        case .help: return "help"
        }
    }
}

struct HomeView: View {
    @State private var currentSheet: SheetType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<8) { index in
                        Text("Item \(index)").subtitle1()
                    }
                    Button {
                        currentSheet = .help
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text("Open drawer").buttonMedium().frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryContainedButtonStyle())

                    ForEach(0..<20) { index in
                        Text("Item \(index)").subtitle1()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 48)
            }
            .padding(.top, 1)
            .sheet(item: $currentSheet, content: {
                Text("Drawer: \($0.id)")
            })
        }
    }
}

#Preview {
    HomeView()
}
