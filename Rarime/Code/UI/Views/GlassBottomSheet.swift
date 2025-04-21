import SwiftUI

struct GlassBottomSheet<Background: View, Content: View>: View {
    let background: Background
    let content: Content

    var minHeight: CGFloat
    var maxHeight: CGFloat
    var maxBlur: CGFloat
    
    private let spaceName = "scroll"
   
    @State private var currentHeight: CGFloat
    @State private var scrollOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
   
    init(
        minHeight: CGFloat,
        maxHeight: CGFloat,
        maxBlur: CGFloat,
        @ViewBuilder background: () -> Background,
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxBlur = maxBlur
        self.background = background()
        self.content = content()
        _currentHeight = State(initialValue: minHeight)
    }
    
    var effectiveHeight: CGFloat {
        let proposedHeight = currentHeight - dragOffset
        return min(max(proposedHeight, minHeight), maxHeight)
    }
    
    var blurRadius: CGFloat {
        return (effectiveHeight - minHeight) / maxHeight * maxBlur
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                background
                    .blur(radius: blurRadius)
                ZStack(alignment: .top) {
                    VStack(spacing: 24) {
                        Capsule()
                            .fill(.bgComponentBaseHovered)
                            .frame(width: 36, height: 5)
                        ChildOffsetReader(offset: $scrollOffset) {
                            content
                        }
                    }
                }
                .frame(width: proxy.size.width, height: effectiveHeight, alignment: .top)
                .offset(y: proxy.size.height - effectiveHeight)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            if currentHeight < maxHeight || (currentHeight == maxHeight && scrollOffset <= 0) {
                                state = value.translation.height
                            }
                        }
                        .onEnded { value in
                            let proposedHeight = currentHeight - value.translation.height
                            let midpoint = (minHeight + maxHeight) / 2
                            currentHeight = proposedHeight > midpoint ? maxHeight : minHeight
                        }
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        GlassBottomSheet(
            minHeight: 360,
            maxHeight: 720,
            maxBlur: 20,
            background: {
                Image(Images.dotCountry)
                    .resizable()
                    .scaledToFit()
            }
        ) {
            VStack(spacing: 8) {
                ForEach(1 ... 10, id: \.self) { _ in
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
