import SwiftUI

struct LikenessView: View {
    let onClose: () -> Void
    var animation: Namespace.ID

    @StateObject var viewModel = LikenessViewModel()

    @State private var isRuleSheetPresented = false
    @State private var isScanSheetPresented = false
    @State private var isFaceScanned = false

    // TODO: use actual count
    let RULES_SET_COUNT = 49421

    var body: some View {
        PullToCloseWrapperView(action: onClose) {
            ZStack(alignment: .topTrailing) {
                AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.top, .trailing], 20)
                ZStack(alignment: .bottom) {
                    GlassBottomSheet(
                        minHeight: 390,
                        maxHeight: 730,
                        bottomOffset: 160,
                        maxBlur: 200,
                        background: {
                            Image(.likenessFace)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.7)
                                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                        }
                    ) {
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Digital likeness")
                                        .h1()
                                        .foregroundStyle(.baseBlack)
                                        .matchedGeometryEffect(
                                            id: AnimationNamespaceIds.title,
                                            in: animation,
                                            properties: .position
                                        )
                                    Text("Set a rule")
                                        .additional1()
                                        .foregroundStyle(Gradients.purpleText)
                                        .matchedGeometryEffect(
                                            id: AnimationNamespaceIds.subtitle,
                                            in: animation,
                                            properties: .position
                                        )
                                    Text("First human-AI Contract")
                                        .body4()
                                        .foregroundStyle(.baseBlack.opacity(0.5))
                                        .padding(.top, 12)
                                        .matchedGeometryEffect(
                                            id: AnimationNamespaceIds.footer,
                                            in: animation,
                                            properties: .position
                                        )
                                }
                                Text("AI can now replicate your face, voice, and identity without asking for your permission. But you never agreed to that, raising a fundamental question: who owns your likeness?\n\nRarimo is building the infrastructure to give you back that control. With this app, you can create a private, verifiable record that defines how your likeness can and can’t be used.\n\nYour face stays on your device. No company owns it. And over time, no AI model will be able to ignore your rule.")
                                    .body3()
                                    .foregroundStyle(.baseBlack.opacity(0.5))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        // HACK: prevent pull to close on empty space
                        .background(.white.opacity(0.01))
                        .padding(.horizontal, 20)
                    }
                    VStack(spacing: 24) {
                        HorizontalDivider()
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(RULES_SET_COUNT.formatted(.number))
                                    .h4()
                                    .foregroundStyle(.baseBlack)
                                Text("Other already set")
                                    .body4()
                                    .foregroundStyle(.baseBlack.opacity(0.5))
                            }
                            Spacer()
                            AppButton(
                                text: "Set the rule",
                                width: 146,
                                action: {
                                    isRuleSheetPresented = true
                                }
                            )
                            .controlSize(.large)
                            .dynamicSheet(isPresented: $isRuleSheetPresented) {
                                LikenessRuleSheetView(
                                    ruleId: LikenessRuleId(rawValue: AppUserDefaults.shared.likenessRuleId) ?? .unset,
                                    onSave: { ruleId in
                                        isRuleSheetPresented = false
                                        AppUserDefaults.shared.likenessRuleId = ruleId.rawValue
                                        isScanSheetPresented = true
                                    }
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .sheet(isPresented: $isScanSheetPresented) {
                if isFaceScanned {
                    LikenessProcessing<LikenessProcessingRegisterTask>(
                        onCompletion: {
                            // TODO: handle completion
                            isFaceScanned = false
                            isScanSheetPresented = false
                        },
                        onBack: {
                            isFaceScanned = false
                            isScanSheetPresented = false
                        }
                    )
                } else {
                    FaceLikenessView(
                        onConfirm: { _ in isFaceScanned = true },
                        onBack: { isScanSheetPresented = false }
                    )
                    .environmentObject(viewModel)
                }
            }
            .background(
                Gradients.purpleBg
                    .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                    .ignoresSafeArea()
            )
        }
    }
}

private struct LikenessRuleItem: Identifiable, Hashable {
    var id: LikenessRuleId
    var title: String
    var icon: ImageResource
    var isSoon: Bool
}

private let LIKENESS_RULE_ITEMS: [LikenessRuleItem] = [
    LikenessRuleItem(
        id: .useAndPay,
        title: String(localized: "Use my likeness and pay me"),
        icon: .moneyDollarCircleLine,
        isSoon: true
    ),
    LikenessRuleItem(
        id: .notUse,
        title: String(localized: "Don’t use my face at all"),
        icon: .subtractFill,
        isSoon: true
    ),
    LikenessRuleItem(
        id: .askFirst,
        title: String(localized: "Ask me\nfirst"),
        icon: .questionLine,
        isSoon: true
    )
]

struct LikenessRuleSheetView: View {
    let ruleId: LikenessRuleId
    let onSave: (_ ruleId: LikenessRuleId) -> Void

    @State private var selectedRuleId: LikenessRuleId

    init(
        ruleId: LikenessRuleId,
        onSave: @escaping (_ ruleId: LikenessRuleId) -> Void
    ) {
        self.ruleId = ruleId
        self.onSave = onSave
        self.selectedRuleId = ruleId
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
                    ForEach(LIKENESS_RULE_ITEMS) { item in
                        Button(action: {
                            selectedRuleId = item.id
                            FeedbackGenerator.shared.impact(.light)
                        }) {
                            VStack(alignment: .leading, spacing: 0) {
                                Image(item.icon)
                                    .iconMedium()
                                    .padding(10)
                                    .background(item.id == selectedRuleId ? .invertedDark : .bgComponentPrimary, in: Circle())
                                    .foregroundStyle(item.id == selectedRuleId ? .invertedLight : .textPrimary)
                                if item.isSoon {
                                    Text("Soon")
                                        .overline3()
                                        .foregroundStyle(.informationalDark)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 4)
                                        .background(.informationalLighter, in: Capsule())
                                        .padding(.top, 20)
                                }
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
                                    .stroke(item.id == selectedRuleId ? .invertedDark : .bgComponentPrimary, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 1)
            }
            AppButton(
                text: selectedRuleId == .unset ? "Set a rule" : "Save",
                action: { onSave(selectedRuleId) }
            )
            .disabled(selectedRuleId == .unset)
            .controlSize(.large)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    LikenessView(onClose: {}, animation: Namespace().wrappedValue)
}
