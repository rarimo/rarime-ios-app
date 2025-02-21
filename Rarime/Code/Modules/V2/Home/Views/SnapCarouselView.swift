import SwiftUI

struct SnapCarouselView: View {
    let views: [AnyView]
    @Binding var index: Int
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    var sensitivity: CGFloat
    var dampFactor: CGFloat
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    init(
        index: Binding<Int>,
        @ViewArrayBuilder content: () -> [AnyView],
        spacing: CGFloat = 44,
        trailingSpace: CGFloat = 88,
        sensitivity: CGFloat = 2.4,
        dampFactor: CGFloat = 0.3
    ) {
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.views = content()
        self.sensitivity = sensitivity
        self.dampFactor = dampFactor
    }
    
    var body: some View {
        GeometryReader { proxy in
            let offsetHeight = self.offsetHeight(for: proxy.size)
            let currentAdjustedOffset = self.adjustedOffset(for: offset)
            let effectiveIndex = self.effectiveIndex(using: currentAdjustedOffset, offsetHeight: offsetHeight)
            VStack(spacing: spacing) {
                ForEach(views.indices, id: \.self) { idx in
                    let distance = abs(CGFloat(idx) - effectiveIndex)
                    let scale = 1 - (0.1 * min(distance, 1))
                    views[idx]
                        .frame(height: proxy.size.height - trailingSpace)
                        .scaleEffect(scale, anchor: .top)
                }
            }
            .offset(y: (CGFloat(currentIndex) * -offsetHeight) + currentAdjustedOffset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.height
                    })
                    .onEnded({ value in
                        let offsetY = value.translation.height
                        let progress = -offsetY / offsetHeight * sensitivity
                        let roundedIndex = progress.rounded()
                        
                        currentIndex = max(min(currentIndex + Int(roundedIndex), views.count - 1), 0)
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetY = value.translation.height
                        let progress = -offsetY / offsetHeight * sensitivity
                        let roundedIndex = progress.rounded()
                        let newIndex = max(min(currentIndex + Int(roundedIndex), views.count - 1), 0)
                                                
                        if newIndex != index {
                            FeedbackGenerator.shared.impact(.light)
                        }
                        
                        index = newIndex
                    })
            )
        }
        .padding(.top, 42)
        .animation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15), value: offset == 0)
    }
    
    private func offsetHeight(for size: CGSize) -> CGFloat {
        size.height - (trailingSpace - spacing)
    }
    
    private func adjustedOffset(for gestureOffset: CGFloat) -> CGFloat {
        if currentIndex == 0 && gestureOffset > 0 {
            return gestureOffset * dampFactor
        } else if currentIndex == views.count - 1 && gestureOffset < 0 {
            return gestureOffset * dampFactor
        }
        return gestureOffset
    }
    
    private func effectiveIndex(using adjustedOffset: CGFloat, offsetHeight: CGFloat) -> CGFloat {
        CGFloat(currentIndex) - (adjustedOffset / offsetHeight)
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
