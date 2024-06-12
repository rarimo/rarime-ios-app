import SwiftUI

struct RewardChip: View {
    let reward: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(String("+\(reward)")).subtitle5()
            Image(Icons.rarimo).iconSmall()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .foregroundStyle(.textSecondary)
        .overlay(RoundedRectangle(cornerRadius: 100).stroke(.componentPrimary))
    }
}

#Preview {
    RewardChip(reward: 10)
}
