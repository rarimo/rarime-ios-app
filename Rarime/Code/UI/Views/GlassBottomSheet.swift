import SwiftUI

struct GlassBottomSheet<Background: View, Content: View, Footer: View>: View {
    let background: Background
    let content: Content
    let footer: Footer

    var minHeight: CGFloat
    var maxHeight: CGFloat
    var maxBlur: CGFloat
    var bottomOffset: CGFloat
    var hideDragIndicator: Bool
    var dimBackground: Bool
    
    private let spaceName = "scroll"
   
    @State private var currentHeight: CGFloat
    @State private var scrollOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
   
    init(
        minHeight: CGFloat,
        maxHeight: CGFloat,
        bottomOffset: CGFloat = 0,
        
        maxBlur: CGFloat,
        hideDragIndicator: Bool = false,
        dimBackground: Bool = false,
        @ViewBuilder background: () -> Background,
        @ViewBuilder footer: () -> Footer = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.bottomOffset = bottomOffset
        self.maxBlur = maxBlur
        self.hideDragIndicator = hideDragIndicator
        self.dimBackground = dimBackground
        
        self.background = background()
        self.footer = footer()
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
    
    var isBgDimmed: Bool {
        return dimBackground && effectiveHeight <= minHeight
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                background
                    .blur(radius: blurRadius)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: blurRadius)
                ZStack(alignment: .bottom) {
                    ZStack(alignment: .top) {
                        VStack(spacing: 8) {
                            if !hideDragIndicator {
                                Capsule()
                                    .fill(.bgComponentPressed)
                                    .frame(width: 36, height: 5)
                            }
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
                .frame(width: proxy.size.width, height: proxy.size.height - bottomOffset, alignment: .top)
                .clipped()
                .mask {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .baseWhite, location: 0.85),
                            .init(color: .baseWhite.opacity(isBgDimmed ? 0.5 : 1), location: 0.925),
                            .init(color: .baseWhite.opacity(isBgDimmed ? 0 : 1), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .animation(.easeInOut, value: isBgDimmed)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    VStack {
        GlassBottomSheet(
            minHeight: 360,
            maxHeight: 720,
            bottomOffset: 150,
            maxBlur: 20,
            dimBackground: true,
            background: {
                Image(.earnBg)
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
