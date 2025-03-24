import SwiftUI
import UIKit

struct TransparentBlurView: UIViewRepresentable {
    let removeAllFilters: Bool

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        Task { @MainActor in
            if let backdropLayer = uiView.layer.sublayers?.first {
                if removeAllFilters {
                    backdropLayer.filters = []
                } else {
                    backdropLayer.filters?.removeAll { filter in
                        String(describing: filter) != "gaussianBlur"
                    }
                }
            }
        }
    }
}

extension View {
    func backgroundBlur(removeAllFilters: Bool = false, bgColor: Color) -> some View {
       self.background {
           ZStack {
               bgColor
               TransparentBlurView(removeAllFilters: false)
           }
           .ignoresSafeArea(.container, edges: .bottom)
       }
   }
}
