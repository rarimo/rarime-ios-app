import SwiftUI

struct HomeCarouselCard: Identifiable {
    let id = UUID()
    let content: () -> AnyView
    let action: () -> Void
    let isShouldDisplay: Bool
    
    init<V: View>(
        isShouldDisplay: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> V
    ) {
        self.isShouldDisplay = isShouldDisplay
        self.action = action
        self.content = { AnyView(content()) }
    }
}

struct SnapCarouselView: View {
    let cards: [HomeCarouselCard]
    @Binding var index: Int
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    var sensitivity: CGFloat
    var dampFactor: CGFloat
    var nextCardScaleFactor: CGFloat
    
    @State private var dragOffset: CGFloat = 0
    
    init(
        index: Binding<Int>,
        cards: [HomeCarouselCard],
        spacing: CGFloat = 40,
        trailingSpace: CGFloat = 68,
        sensitivity: CGFloat = 2.5,
        dampFactor: CGFloat = 0.4,
        nextCardScaleFactor: CGFloat = 0.9
    ) {
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.cards = cards
        self.sensitivity = sensitivity
        self.dampFactor = dampFactor
        self.nextCardScaleFactor = nextCardScaleFactor
    }
    
    var body: some View {
        GeometryReader { proxy in
            let containerHeight = proxy.size.height
            let cardHeight = (containerHeight - trailingSpace) * nextCardScaleFactor
            let freeSpace = containerHeight - cardHeight
            let offsetHeight = cardHeight + spacing
            let currentAdjustedOffset = self.adjustedOffset(for: dragOffset)
            let effectiveIndex = self.effectiveIndex(using: currentAdjustedOffset, offsetHeight: offsetHeight)
            VStack(spacing: spacing) {
                ForEach(0..<cards.count, id: \.self) { idx in
                    let distance = abs(CGFloat(idx) - effectiveIndex)
                    let scale = 1 - ((1 - nextCardScaleFactor) * min(distance, 1))
                    
                    cards[idx].content()
                        .frame(height: cardHeight)
                        .scaleEffect(scale, anchor: .top)
                        .onTapGesture {
                            cards[idx].action()
                        }
                }
            }
            .offset(y:
                (CGFloat(index) * -offsetHeight) +
                currentAdjustedOffset +
                (freeSpace / 2) -
                (spacing / 2)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let offsetY = value.translation.height
                        let progress = -offsetY / offsetHeight * sensitivity
                        let delta = min(max(Int(progress.rounded()), -1), 1)
                        
                        withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15)) {
                            let newIndex = max(min(index + delta, cards.count - 1), 0)
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
    
    private func adjustedOffset(for gestureOffset: CGFloat) -> CGFloat {
        if index == 0 && gestureOffset > 0 {
            return gestureOffset * dampFactor
        } else if index == cards.count - 1 && gestureOffset < 0 {
            return gestureOffset * dampFactor
        }
        return gestureOffset
    }
    
    private func effectiveIndex(using adjustedOffset: CGFloat, offsetHeight: CGFloat) -> CGFloat {
        CGFloat(index) - (adjustedOffset / offsetHeight)
    }
}

#Preview {
    V2HomeView()
        .environmentObject(V2MainView.ViewModel())
        .environmentObject(PassportManager())
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
        .environmentObject(ConfigManager())
        .environmentObject(NotificationManager())
        .environmentObject(ExternalRequestsManager())
}
