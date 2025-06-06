import SwiftUI

struct DetectableScrollView<Content: View>: View {
    let onTop: () -> Void
    let onBottom: () -> Void
    let content: () -> Content

    @State private var contentHeight: CGFloat = .zero
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var hasReachedTop = false
    @State private var hasReachedBottom = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    Color.clear
                        .frame(height: 0)
                        .onChange(of: geo.frame(in: .named("scroll")).minY) { value in
                            if value >= 90 {
                                if !hasReachedTop {
                                    hasReachedTop = true
                                    onTop()
                                }
                            } else {
                                hasReachedTop = false
                            }

                            if contentHeight > 0, scrollViewHeight > 0,
                               value <= scrollViewHeight - contentHeight
                            {
                                if !hasReachedBottom {
                                    hasReachedBottom = true
                                    onBottom()
                                }
                            } else {
                                hasReachedBottom = false
                            }
                        }
                }
                .frame(height: 0)
                content()
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    contentHeight = geo.size.height
                                }
                                .onChange(of: geo.size.height) { newValue in
                                    contentHeight = newValue
                                }
                        }
                    )
            }
        }
        .coordinateSpace(name: "scroll")
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        scrollViewHeight = geo.size.height
                    }
                    .onChange(of: geo.size.height) { newValue in
                        scrollViewHeight = newValue
                    }
            }
        )
    }
}

#Preview {
    DetectableScrollView(onTop: {}, onBottom: {}) {
        VStack {
            ForEach(0 ..< 10) { _ in
                Text("Test")
            }
        }
    }
}
