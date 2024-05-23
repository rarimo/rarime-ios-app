import SwiftUI

struct RewardChipView: View {
    let reward: Int
    let isActive: Bool

    init(reward: Int, isActive: Bool = false) {
        self.reward = reward
        self.isActive = isActive
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(String("+\(reward)")).subtitle5()
            Image(Icons.rarimo).iconSmall()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .foregroundStyle(isActive ? .textPrimary : .textSecondary)
        .background(isActive ? .warningLight : .componentPrimary)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

#Preview {
    VStack(spacing: 24) {
        RewardChipView(reward: 50, isActive: true)
        RewardChipView(reward: 100)
    }
}
