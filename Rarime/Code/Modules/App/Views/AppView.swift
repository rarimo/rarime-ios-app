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
            if !viewModel.isFaceIdSet {
                MainView().transition(.backslide)
            } else if viewModel.isPasscodeSet {
                EnableFaceIdView().transition(.backslide)
            } else if viewModel.isIntroFinished {
                EnablePasscodeView().transition(.backslide)
            } else {
                IntroView().transition(.backslide)
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    AppView()
}
