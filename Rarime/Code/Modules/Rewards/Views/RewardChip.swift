import SwiftUI

struct RewardChip: View {
    var reward: Double
    var active: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text(String("+\(reward.formatted())")).subtitle7()
            Image(Icons.rarimo).iconSmall()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .foregroundStyle(active ? .successMain : .textSecondary)
        .background(active ? .successLighter : .clear, in: RoundedRectangle(cornerRadius: 100))
        .overlay(active ? nil : RoundedRectangle(cornerRadius: 100).stroke(.bgComponentPrimary))
    }
}

#Preview {
    VStack {
        RewardChip(reward: 10.0)
        RewardChip(reward: 10.0, active: true)
    }
}
