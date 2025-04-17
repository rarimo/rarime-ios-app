import SwiftUI

struct ChildOffsetReader<Content: View>: View {
    @Binding var offset: CGFloat
    
    let content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newValue in
                offset = newValue
            }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
