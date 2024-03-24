//
//  LottieView.swift
//  Rarime
//
//  Created by Ivan Lele on 18.03.2024.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var animationFileName: String
    let loopMode: LottieLoopMode
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: animationFileName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit

        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
         
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
}

#Preview {
    LottieView(animationFileName: "passportScanning", loopMode: .loop)
        .frame(width: 300)
}
