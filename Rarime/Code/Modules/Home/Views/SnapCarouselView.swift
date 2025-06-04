import SwiftUI

struct SnapCarouselCard: Identifiable {
    let id = UUID()
    let content: () -> AnyView
    let action: () -> Void
    let isVisible: Bool
    
    init<V: View>(
        isVisible: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> V
    ) {
        self.isVisible = isVisible
        self.action = action
        self.content = { AnyView(content()) }
    }
}

struct SnapCarouselView<BottomContent: View>: View {
    @Binding var index: Int
    let cards: [SnapCarouselCard]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    var sensitivity: CGFloat
    var dampFactor: CGFloat
    var nextCardScaleFactor: CGFloat
    var bottomContentHeight: CGFloat
    let bottomContent: BottomContent

    @State private var dragOffset: CGFloat = 0

    init(
        index: Binding<Int>,
        cards: [SnapCarouselCard],
        spacing: CGFloat = 40,
        trailingSpace: CGFloat = 68,
        sensitivity: CGFloat = 2.5,
        dampFactor: CGFloat = 0.4,
        nextCardScaleFactor: CGFloat = 0.9,
        bottomContentHeight: CGFloat = 0,
        @ViewBuilder bottomContent: @escaping () -> BottomContent = { EmptyView() }
    ) {
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.cards = cards
        self.sensitivity = sensitivity
        self.dampFactor = dampFactor
        self.nextCardScaleFactor = nextCardScaleFactor
        self.bottomContentHeight = bottomContentHeight
        self.bottomContent = bottomContent()
    }
    
    var body: some View {
        GeometryReader { proxy in
            let containerHeight = proxy.size.height
            let cardHeight = (containerHeight - trailingSpace) * nextCardScaleFactor
            let freeSpace = containerHeight - cardHeight
            let offsetStep = cardHeight + spacing
            
            let adjustedDrag = adjustedOffset(for: dragOffset)
            let floatingIndex = effectiveIndex(using: adjustedDrag, offsetStep: offsetStep)
            
            VStack(spacing: spacing) {
                ForEach(0 ..< totalSlots, id: \.self) { idx in
                    if idx < cards.count {
                        let distance = idx == cards.count - 1 ? 0 : abs(CGFloat(idx) - floatingIndex)
                        let scale = 1 - ((1 - nextCardScaleFactor) * min(distance, 1))
                        
                        cards[idx].content()
                            .frame(height: cardHeight)
                            .scaleEffect(scale, anchor: .top)
                            .onTapGesture {
                                cards[idx].action()
                            }
                    } else {
                        bottomContent
                    }
                }
            }
            .offset(y: yOffset(
                containerHeight: containerHeight,
                cardHeight: cardHeight,
                freeSpace: freeSpace,
                offsetStep: offsetStep,
                adjustedDrag: adjustedDrag
            ))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let progress = -value.translation.height / offsetStep * sensitivity
                        let delta = min(max(Int(progress.rounded()), -1), 1)
                        
                        withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15)) {
                            let newIndex = max(min(index + delta, totalSlots - 1), 0)
                            if newIndex != index {
                                FeedbackGenerator.shared.impact(.light)
                            }
                            index = newIndex
                            dragOffset = 0
                        }
                    }
            )
        }
    }
    
    private var totalSlots: Int {
        cards.count + (bottomContentHeight > 0 ? 1 : 0)
    }
    
    private func adjustedOffset(for gestureOffset: CGFloat) -> CGFloat {
        let atTop = (index == 0 && gestureOffset > 0)
        let atLastCard = (index == cards.count - 1 && gestureOffset < 0)
        let atBottom = index >= cards.count
        
        let factor = (atTop || atLastCard || atBottom) ? dampFactor : 1
        return gestureOffset * factor
    }
    
    private func effectiveIndex(using adjustedDrag: CGFloat, offsetStep: CGFloat) -> CGFloat {
        CGFloat(index) - (adjustedDrag / offsetStep)
    }
    
    private func yOffset(
        containerHeight: CGFloat,
        cardHeight: CGFloat,
        freeSpace: CGFloat,
        offsetStep: CGFloat,
        adjustedDrag: CGFloat
    ) -> CGFloat {
        if index < cards.count {
            return (CGFloat(index) * -offsetStep)
                + adjustedDrag
                + (freeSpace / 2)
                - (spacing / 2)
        }
        
        let lastCardCenteredOffset =
            (CGFloat(cards.count - 1) * -offsetStep)
                + (freeSpace / 2)
                - (spacing / 2)
        
        return lastCardCenteredOffset
            - spacing
            - bottomContentHeight
            + adjustedDrag
    }
}

private struct PreviewView: View {
    @State private var currentIndex: Int = 0
    
    let sampleCards: [SnapCarouselCard] = [
        SnapCarouselCard(action: { print("Card 0 tapped") }) { Color.green },
        SnapCarouselCard(action: { print("Card 1 tapped") }) { Color.purple },
        SnapCarouselCard(action: { print("Card 2 tapped") }) { Color.cyan }
    ]
    
    var body: some View {
        VStack {
            SnapCarouselView(
                index: $currentIndex,
                cards: sampleCards,
                spacing: 32,
                trailingSpace: 100,
                sensitivity: 2.5,
                dampFactor: 0.4,
                nextCardScaleFactor: 0.9,
                bottomContentHeight: 56
            ) {
                Image(.rarime)
                    .iconMedium()
            }
            .frame(height: UIScreen.main.bounds.height * 0.9)
        }
    }
}

#Preview {
    PreviewView()
}
