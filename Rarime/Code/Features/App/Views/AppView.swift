//
//  EntryView.swift
//  Rarime
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
           MainView()
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
}
