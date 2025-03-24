import SwiftUI

struct ShadowConfig {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct MultipleShadowsModifier: ViewModifier {
    let shadows: [ShadowConfig]
    
    func body(content: Content) -> some View {
        var modifiedContent = AnyView(content)
        for shadow in shadows {
            modifiedContent = AnyView(
                modifiedContent.shadow(
                    color: shadow.color,
                    radius: shadow.radius,
                    x: shadow.x,
                    y: shadow.y
                )
            )
        }
        return modifiedContent
    }
}

extension View {
    func applyShadows(_ shadows: [ShadowConfig]) -> some View {
        self.modifier(MultipleShadowsModifier(shadows: shadows))
    }
}
