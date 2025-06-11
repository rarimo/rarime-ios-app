import SwiftUI

private let displayedLikenessRules: [LikenessRule] = [
    .useAndPay,
    .notUse,
    .askFirst
]

struct LikenessSetRuleView: View {
    @EnvironmentObject private var likenessManager: LikenessManager

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
                Text(likenessManager.isRegistered ? "Update the rule" : "Set a rule")
                    .h2()
                    .foregroundStyle(.textPrimary)
                Text("The rules are yours to change")
                    .body3()
                    .foregroundStyle(.textSecondary)
            }
            VStack(spacing: 12) {
                ForEach(displayedLikenessRules, id: \.self) { item in
                    Button(action: {
                        selectedRule = item
                        FeedbackGenerator.shared.impact(.light)
                    }) {
                        HStack(spacing: 20) {
                            Image(item.icon)
                                .iconMedium()
                                .padding(10)
                                .background(item == selectedRule ? .invertedDark : .bgComponentPrimary, in: Circle())
                                .foregroundStyle(item == selectedRule ? .invertedLight : .textPrimary)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Soon")
                                    .overline3()
                                    .foregroundStyle(.informationalDark)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                                    .background(.informationalLighter, in: Capsule())
                                Text(item.title)
                                    .subtitle6()
                                    .foregroundStyle(.textPrimary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(item == selectedRule ? .bgComponentPrimary : .clear, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(item == selectedRule ? .clear : .bgComponentPrimary, lineWidth: 1)
                        )
                    }
                }
            }
            AppButton(
                text: saveButtonText,
                loading: likenessManager.isRuleUpdating,
                action: { onSave(selectedRule) }
            )
            .disabled(selectedRule == .unset)
            .controlSize(.large)
        }
        .padding(20)
    }

    var saveButtonText: LocalizedStringResource {
        if selectedRule == .unset {
            return "Set a rule"
        }

        if likenessManager.isRegistered {
            return "Update"
        }

        return "Save"
    }
}

#Preview {
    LikenessSetRuleView(
        rule: .unset,
        onSave: { _ in }
    )
    .environmentObject(LikenessManager.shared)
}
