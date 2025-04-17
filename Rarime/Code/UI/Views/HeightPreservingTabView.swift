import SwiftUI

struct HeightPreservingTabView<SelectionValue: Hashable, Content: View>: View {
    var selection: Binding<SelectionValue>?
    @ViewBuilder var content: () -> Content

    @State private var currentHeight: CGFloat = 1

    var body: some View {
        TabView(selection: selection) {
            content()
        }
        .frame(height: currentHeight)
        .onPreferenceChange(TabViewHeightPreferenceKey<SelectionValue>.self) { heights in
            if let selected = selection?.wrappedValue,
               let newHeight = heights[selected] {
                withAnimation {
                    currentHeight = newHeight
                }
            }
        }
    }
}

struct TabViewHeightPreferenceKey<SelectionValue: Hashable>: PreferenceKey {
    typealias Value = [SelectionValue: CGFloat]
    
    static var defaultValue: [SelectionValue: CGFloat] { [:] }
    
    static func reduce(value: inout [SelectionValue: CGFloat], nextValue: () -> [SelectionValue: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
