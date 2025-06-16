import SwiftUI

struct LikenessView: View {
    @EnvironmentObject private var likenessManager: LikenessManager

    let onClose: () -> Void
    var animation: Namespace.ID

    @State private var isRuleSheetPresented = false
    @State private var isScanSheetPresented = false
    @State private var isSuccessTooltipShown = false

    // TODO: use actual count
    let RULES_SET_COUNT = 49421

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PullToCloseWrapperView(action: onClose) {
                ZStack(alignment: .bottom) {
                    GlassBottomSheet(
                        minHeight: 410,
                        maxHeight: 730,
                        bottomOffset: likenessManager.isRegistered ? 0 : 146,
                        maxBlur: 200,
                        dimBackground: true,
                        background: {
                            ZStack {
                                Image(.likenessBg)
                                    .resizable()
                                    .scaledToFit()
                                    .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                                    .ignoresSafeArea()
                            }
                            .background(.invertedLight)
                        }
                    ) {
                        mainSheetContent
                    }
                    if !likenessManager.isRegistered {
                        footer
                    }
                }
                .background(.invertedLight)
            }
            .dynamicSheet(isPresented: $isRuleSheetPresented) {
                LikenessSetRuleView(rule: likenessManager.rule, onSave: onRuleUpdate)
            }
            .sheet(isPresented: $isScanSheetPresented) {
                LikenessScanView(
                    onComplete: {
                        isScanSheetPresented = false
                        showSuccessTooltip()
                    },
                    onClose: {
                        isScanSheetPresented = false
                        likenessManager.setFaceImage(nil)
                    }
                )
                .interactiveDismissDisabled()
                .environmentObject(likenessManager)
            }
            Button(action: onClose) {
                Image(.closeFill)
                    .iconMedium()
                    .foregroundStyle(.textPrimary)
                    .padding(10)
                    .background(.bgComponentPrimary, in: Circle())
            }
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
    }

    var mainSheetContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                if likenessManager.isRegistered {
                    Text("My Rule:")
                        .subtitle5()
                        .foregroundStyle(.invertedDark)
                        .padding(.bottom, 12)
                    ZStack(alignment: .topLeading) {
                        if isSuccessTooltipShown {
                            ruleTooltip
                        }
                        Button(action: { isRuleSheetPresented = true }) {
                            (
                                Text(likenessManager.rule.title) +
                                    Text(verbatim: " ") +
                                    Text(Image(.arrowDownSLine))
                                    .foregroundColor(.textSecondary)
                            )
                            .additional1()
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Gradients.limeText)
                            .frame(maxWidth: 306, alignment: .leading)
                        }
                    }
                } else {
                    Text("Digital likeness")
                        .h1()
                        .foregroundStyle(.invertedDark)
                    Text("Set a rule")
                        .additional1()
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(Gradients.limeText)
                    Text("Your data, your rules")
                        .body4()
                        .foregroundStyle(.textSecondary)
                        .padding(.top, 12)
                }
            }
            if likenessManager.isRegistered {
                HorizontalDivider()
            }
            Text("AI can now replicate your face, voice, and identity without asking for your permission. But you never agreed to that, raising a fundamental question: who owns your likeness?\n\nRarimo is building the infrastructure to give you back that control. With this app, you can create a private, verifiable record that defines how your likeness can and can’t be used.\n\nYour face stays on your device. No company owns it. And over time, no AI model will be able to ignore your rule.")
                .body4()
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .padding(.bottom, 180)
        .background(.invertedLight, in: RoundedRectangle(cornerRadius: 16))
    }

    var footer: some View {
        VStack(spacing: 24) {
            HorizontalDivider()
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(RULES_SET_COUNT.formatted(.number))
                        .h4()
                        .foregroundStyle(.invertedDark)
                    Text("Other already set")
                        .body4()
                        .foregroundStyle(.textSecondary)
                }
                Spacer()
                AppButton(
                    text: likenessManager.isRegistered ? "Update the rule" : "Set a rule",
                    width: 146,
                    action: { isRuleSheetPresented = true }
                )
                .controlSize(.large)
            }
        }
        .padding(20)
    }

    var ruleTooltip: some View {
        ZStack(alignment: .bottomLeading) {
            Text("You can update it anytime by clicking the title")
                .body5()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.baseBlack, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.baseWhite)
                .frame(maxWidth: 200)
                .fixedSize(horizontal: false, vertical: true)
            Rectangle()
                .fill(.baseBlack)
                .frame(width: 8, height: 8)
                .rotationEffect(.degrees(45))
                .offset(x: 18, y: 4)
        }
        .offset(x: -6, y: -66)
    }

    private func showSuccessTooltip() {
        withAnimation {
            isSuccessTooltipShown = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                isSuccessTooltipShown = false
            }
        }
    }

    private func onRuleUpdate(_ rule: LikenessRule) {
        Task {
            defer { isRuleSheetPresented = false }

            do {
                likenessManager.setRule(rule)

                if likenessManager.isRegistered {
                    likenessManager.isRuleUpdating = true
                    defer { likenessManager.isRuleUpdating = false }

                    try await likenessManager.updateRule()

                    FeedbackGenerator.shared.notify(.success)
                    AlertManager.shared.emitSuccess("Rule updated successfully")
                } else {
                    isScanSheetPresented = true
                }
            } catch {
                FeedbackGenerator.shared.notify(.error)
                AlertManager.shared.emitError(.unknown("Unknown error occurred"))
                LoggerUtil.common.error("Failed to update the rule: \(error)")
            }
        }
    }
}

#Preview {
    LikenessView(onClose: {}, animation: Namespace().wrappedValue)
        .environmentObject(LikenessManager())
}
