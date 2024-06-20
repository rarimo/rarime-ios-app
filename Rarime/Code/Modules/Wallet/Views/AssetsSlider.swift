import SwiftUI

struct AssetsSlider: View {
    @State private var selectedTab = 0
    @State private var offset = CGFloat.zero

    let walletAssets: [WalletAsset]
    let isLoading: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("ASSETS (\(walletAssets.count))")
                    .overline2()
                    .foregroundStyle(.textSecondary)
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0 ..< walletAssets.count, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 100)
                            .frame(width: idx == selectedTab ? 16 : 8, height: 8)
                            .foregroundColor(idx == selectedTab ? .primaryMain : .componentPrimary)
                            .onTapGesture { selectedTab = idx }
                    }
                }
            }
            .padding(.horizontal, 20)
            GeometryReader { geo in
                let width = geo.size.width * 0.8
                let spacing: CGFloat = 12
                LazyHStack(spacing: spacing) {
                    Color.clear.frame(width: 8)
                    ForEach(0 ..< walletAssets.count, id: \.self) { idx in
                        AssetCard(
                            asset: walletAssets[idx],
                            isLoading: isLoading
                        )
                        .frame(width: width)
                    }
                }
                .offset(x: CGFloat(-selectedTab) * (width + spacing) + offset)
                .animation(.easeOut, value: selectedTab)
                .gesture(
                    DragGesture()
                        .onChanged { value in offset = value.translation.width }
                        .onEnded { value in
                            withAnimation(.easeOut) {
                                offset = value.predictedEndTranslation.width
                                selectedTab -= Int((offset / width).rounded())
                                selectedTab = max(0, min(selectedTab, walletAssets.count - 1))
                                offset = 0
                            }
                        }
                )
            }
            .frame(height: 72)
        }
        .onChange(of: selectedTab) { _ in
            FeedbackGenerator.shared.impact(.light)
        }
    }
}

private struct AssetCard: View {
    let asset: WalletAsset
    let isLoading: Bool

    var icon: String {
        switch asset.token {
        case .rmo: Icons.rarimo
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .iconMedium()
                .padding(10)
                .background(.componentPrimary, in: Circle())
                .foregroundStyle(.textPrimary)
            Text("Total \(asset.token.rawValue)")
                .body3()
                .foregroundStyle(.textSecondary)
            Spacer()
            if isLoading {
                ProgressView()
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(asset.balance.formatted())
                        .subtitle4()
                        .foregroundStyle(.textPrimary)
                    Text(try! String(asset.usdBalance == nil ? "---" : "≈$\((asset.usdBalance ?? 0).formatted())"))
                        .caption3()
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(16)
        .background(.backgroundOpacity, in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    AssetsSlider(
        walletAssets: [WalletAsset(token: WalletToken.rmo, balance: 3, usdBalance: nil)],
        isLoading: false
    )
}
