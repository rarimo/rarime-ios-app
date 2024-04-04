//
//  LottieView.swift
//  Rarime
//
//  Created by Ivan Lele on 18.03.2024.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var animation: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: animation)
        animationView.loopMode = loopMode
        animationView.contentMode = contentMode

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
    LottieView(animation: Animations.passport, contentMode: .scaleToFill)
}
