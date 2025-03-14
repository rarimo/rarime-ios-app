import SwiftUI
import UIKit

struct TransparentBlurView: UIViewRepresentable {
    let removeAllFilters: Bool

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            if let backdropLayer = uiView.layer.sublayers?.first {
                if removeAllFilters {
                    backdropLayer.filters = []
                } else {
                    backdropLayer.filters?.removeAll(where: { filter in
                        String(describing: filter) != "gaussianBlur"
                    })
                }
            }
        }
    }
}

extension View {
    func transparentBlur(removeAllFilters: Bool = false) -> some View {
       self.background(
           TransparentBlurView(removeAllFilters: removeAllFilters)
       )
   }
}
