import PullToRefreshSwiftUI
import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    var onRefresh: () async throws -> Void
    @ViewBuilder var content: (Bool) -> Content
    @State private var isRefreshing = false

    private let iconSize: CGFloat = 24

    @MainActor
    private func refresh() async {
        defer { isRefreshing = false }
        do {
            isRefreshing = true
            try await onRefresh()
        } catch {
            LoggerUtil.common.error("[RefreshableScrollView] Refresh error: \(error.localizedDescription)")
        }
    }

    var body: some View {
        PullToRefreshScrollView(
            options: PullToRefreshScrollViewOptions(
                pullToRefreshAnimationHeight: 60,
                animationDuration: 0.3,
                animatePullingViewPresentation: true,
                animateRefreshingViewPresentation: true
            ),
            isRefreshing: $isRefreshing,
            onRefresh: { Task { await refresh() } },
            animationViewBuilder: { state in
                switch state {
                case .idle:
                    Color.clear
                case .pulling(let progress):
                    Image(Icons.rarime).square(progress * iconSize)
                case .refreshing, .finishing:
                    PulseAnimationView {
                        Image(Icons.rarime).square(iconSize)
                    }
                }
            }
        ) { _ in
            content(isRefreshing)
        }
    }
}

private struct PulseAnimationView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @State var isScaled = false

    var body: some View {
        content()
            .scaleEffect(isScaled ? 1.2 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    isScaled.toggle()
                }
            }
    }
}

#Preview {
    RefreshableScrollView(
        onRefresh: { try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC) }
    ) { _ in
        VStack {
            Color(.componentPrimary)
                .frame(height: 1000)
        }
    }
}
