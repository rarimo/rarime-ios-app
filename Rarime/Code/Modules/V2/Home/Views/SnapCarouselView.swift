import SwiftUI

struct SnapCarouselView: View {
    let views: [AnyView]
    @Binding var index: Int
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    var sensitivity: CGFloat
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    init(
        index: Binding<Int>,
        @ViewArrayBuilder content: () -> [AnyView],
        spacing: CGFloat = 44,
        trailingSpace: CGFloat = 88,
        sensitivity: CGFloat = 3
    ) {
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.views = content()
        self.sensitivity = sensitivity
    }
    
    var body: some View {
        GeometryReader { proxy in
            let offsetHeight = proxy.size.height - (trailingSpace - spacing)
            VStack(spacing: spacing) {
                ForEach(views.indices, id: \.self) { idx in
                    views[idx]
                        .frame(height: proxy.size.height - trailingSpace)
                        .scaleEffect(idx == index ? 1.0 : 0.8, anchor: .top)
                        .animation(.easeInOut(duration: 0.4), value: index)
                }
            }
            .offset(y: (CGFloat(currentIndex) * -offsetHeight) + offset)
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
                        
                        index = max(min(currentIndex + Int(roundedIndex), views.count - 1), 0)
                    })
            )
        }
        .padding(.top, 42)
        .animation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 15), value: offset == 0)
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
