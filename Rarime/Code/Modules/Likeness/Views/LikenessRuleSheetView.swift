import SwiftUI

private let displayedLikenessRules: [LikenessRule] = [
    .useAndPay,
    .notUse,
    .askFirst
]

struct LikenessSetRuleView: View {
    let rule: LikenessRule
    let onSave: (_ rule: LikenessRule) -> Void

    @State private var selectedRule: LikenessRule

    init(
        rule: LikenessRule,
        onSave: @escaping (_ rule: LikenessRule) -> Void
    ) {
        self.rule = rule
        self.onSave = onSave
        self.selectedRule = rule
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Set a rule")
                    .h2()
                    .foregroundStyle(.textPrimary)
                Text("The rules are yours to change")
                    .body3()
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(displayedLikenessRules, id: \.self) { item in
                        Button(action: {
                            selectedRule = item
                            FeedbackGenerator.shared.impact(.light)
                        }) {
                            VStack(alignment: .leading, spacing: 0) {
                                Image(item.icon)
                                    .iconMedium()
                                    .padding(10)
                                    .background(item == selectedRule ? .invertedDark : .bgComponentPrimary, in: Circle())
                                    .foregroundStyle(item == selectedRule ? .invertedLight : .textPrimary)
                                Text("Soon")
                                    .overline3()
                                    .foregroundStyle(.informationalDark)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                                    .background(.informationalLighter, in: Capsule())
                                    .padding(.top, 20)
                                Text(item.title)
                                    .subtitle6()
                                    .foregroundStyle(.textPrimary)
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 8)
                            }
                            .padding(16)
                            .frame(width: 148, alignment: .leading)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(item == selectedRule ? .invertedDark : .bgComponentPrimary, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 1)
            }
            AppButton(
                text: selectedRule == .unset ? "Set a rule" : "Save",
                action: { onSave(selectedRule) }
            )
            .disabled(selectedRule == .unset)
            .controlSize(.large)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    LikenessSetRuleView(
        rule: .unset,
        onSave: { _ in }
    )
}
