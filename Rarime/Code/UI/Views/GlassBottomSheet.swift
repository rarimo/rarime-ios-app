import SwiftUI

struct GlassBottomSheet<Content: View>: View {
    let content: Content

    var minHeight: CGFloat
    var maxHeight: CGFloat
    var sensitivity: CGFloat
    var canOpenSheet: Bool
    
    private let spaceName = "scroll"
   
    @State private var currentHeight: CGFloat
    @State private var bgOpacity: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
   
    init(
        minHeight: CGFloat = 360,
        maxHeight: CGFloat = 670,
        sensitivity: CGFloat = 3,
        canOpenSheet: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.sensitivity = sensitivity
        self.canOpenSheet = canOpenSheet
        self.content = content()
        _currentHeight = State(initialValue: minHeight)
    }
    
    var effectiveHeight: CGFloat {
        let proposedHeight = currentHeight - dragOffset
        return min(max(proposedHeight, minHeight), maxHeight)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                TransparentBlurView()
                VStack(spacing: 24) {
                    Capsule()
                        .fill(.bgComponentBaseHovered)
                        .frame(width: 36, height: 5)
                    ScrollView(.vertical, showsIndicators: false) {
                        ChildOffsetReader(offset: $scrollOffset) {
                            content
                        }
                    }
                    .coordinateSpace(name: spaceName)
                    .scrollDisabled(currentHeight < maxHeight)
                }
                .disabled(!canOpenSheet)
            }
            .frame(width: proxy.size.width, height: effectiveHeight, alignment: .top)
            .offset(y: proxy.size.height - effectiveHeight)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if currentHeight < maxHeight || (currentHeight == maxHeight && scrollOffset <= 0) {
                           state = value.translation.height * sensitivity
                       }
                    }
                    .onEnded { value in
                        let proposedHeight = currentHeight - (value.translation.height * sensitivity)
                        let midpoint = (minHeight + maxHeight) / 2
                        currentHeight = proposedHeight > midpoint ? maxHeight : minHeight
                    }
            )
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        GlassBottomSheet(minHeight: 360, maxHeight: 720) {
            VStack(spacing: 8) {
                ForEach(1...10, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.successMain)
                        .frame(width: .infinity, height: 250)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    .frame(maxHeight: .infinity)
    .background(Gradients.gradientFirst)
}
