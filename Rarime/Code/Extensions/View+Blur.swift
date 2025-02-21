import SwiftUI

private struct VisualEffectBlur: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    func blurBackground(style: UIBlurEffect.Style = .systemThinMaterial) -> some View {
        self.background(
            VisualEffectBlur(style: style)
        )
    }
}
