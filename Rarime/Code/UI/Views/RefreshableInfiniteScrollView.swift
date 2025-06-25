import SwiftUI

struct RefreshableInfiniteScrollView<Content: View>: View {
    let hasMore: Bool
    let onRefresh: @Sendable () async -> Void
    let onLoadMore: @Sendable () async -> Void
    @ViewBuilder let content: () -> Content

    @State private var isLoadingMore = false

    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0

    var threshold: CGFloat = 80

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    Color.orange
                        .onChange(of: geo.frame(in: .named("scroll")).minY) { offset in
                            Task { await checkLoadMore(offset: offset) }
                        }
                }
                .frame(height: 0)

                content()

                if isLoadingMore {
                    ProgressView()
                        .padding(.vertical, 8)
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { contentHeight = geo.size.height }
                        .onChange(of: geo.size.height) { newValue in
                            contentHeight = newValue
                        }
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { scrollViewHeight = geo.size.height }
                    .onChange(of: geo.size.height) { newValue in
                        scrollViewHeight = newValue
                    }
            }
        )
        .refreshable {
            await Task { await onRefresh() }.value
        }
    }

    @MainActor
    private func checkLoadMore(offset: CGFloat) async {
        guard contentHeight > 0,
              scrollViewHeight > 0,
              offset <= scrollViewHeight - contentHeight + threshold,
              hasMore,
              !isLoadingMore
        else { return }

        isLoadingMore = true
        await onLoadMore()
        isLoadingMore = false
    }
}

private struct RefreshDemoView: View {
    @State private var items = (1 ... 20).map { "Item \($0)" }

    var body: some View {
        RefreshableInfiniteScrollView(
            hasMore: items.count < 26,
            onRefresh: { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                items.insert(contentsOf: [
                    "New \(items.count + 1)",
                    "New \(items.count + 2)",
                ], at: 0)
            },
            onLoadMore: { @MainActor in
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                let nextStart = items.count + 1
                items.append(contentsOf: [
                    "More \(nextStart)",
                    "More \(nextStart + 1)",
                    "More \(nextStart + 2)",
                ])
            }
        ) {
            ForEach(items, id: \.self) { text in
                Text(text)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.95))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
        }
        .animation(.default, value: items)
        .padding(.top, 12)
    }
}

#Preview {
    RefreshDemoView()
}
