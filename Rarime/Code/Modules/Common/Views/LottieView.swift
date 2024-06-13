import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    var animation: ThemedAnimation
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        let animationName = colorScheme == .dark ? animation.dark : animation.light
        let animationView = LottieAnimationView(name: animationName)
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
    LottieView(animation: Animations.incognito, contentMode: .scaleToFill)
}
