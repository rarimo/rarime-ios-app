//
//  AppView.swift
//  Rarime
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            if viewModel.isFaceIdSet {
                MainView()
            } else if viewModel.isPasscodeSet {
                EnableFaceIdView()
                    .environmentObject(viewModel)
            } else if viewModel.isIntroFinished {
                EnablePasscodeView()
                    .environmentObject(viewModel)
            } else {
                IntroView()
                    .environmentObject(viewModel)
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
}
