import SwiftUI

struct PullToCloseWrapperView<Content: View>: View {
    var dragThreshold: CGFloat = 100
    var minDistance: CGFloat = 30
    let action: () -> Void
    let content: Content

    init(
        dragThreshold: CGFloat = 100,
        minDistance: CGFloat = 30,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.dragThreshold = dragThreshold
        self.minDistance = minDistance
        self.action = action
        self.content = content()
    }

    var body: some View {
        content
            .gesture(
                DragGesture(minimumDistance: minDistance)
                    .onEnded { value in
                        if value.translation.height > dragThreshold {
                            action()
                        }
                    }
            )
    }
}
