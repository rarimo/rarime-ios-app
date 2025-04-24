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
        PullToCloseWrapperView(action: onClose) {
            ZStack(alignment: .topTrailing) {
                AppIconButton(variant: .secondary, icon: Icons.closeFill, action: onClose)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.top, .trailing], 20)
                ZStack(alignment: .bottom) {
                    GlassBottomSheet(
                        minHeight: 410,
                        maxHeight: 730,
                        bottomOffset: likenessManager.isRegistered ? 0 : 146,
                        maxBlur: 200,
                        dimBackground: true,
                        background: {
                            if let faceImage = likenessManager.faceImage {
                                LikenessFaceImageView(image: faceImage)
                                    .padding(.top, 80)
                            } else {
                                Image(.likenessFace)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(0.75)
                                    .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                            }
                        }
                    ) {
                        mainSheetContent
                    }
                    if !likenessManager.isRegistered {
                        footer
                    }
                }
                .dynamicSheet(isPresented: $isRuleSheetPresented) {
                    LikenessSetRuleView(
                        rule: likenessManager.rule,
                        onSave: { rule in
                            isRuleSheetPresented = false
                            likenessManager.setRule(rule)
                            if !likenessManager.isRegistered {
                                isScanSheetPresented = true
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $isScanSheetPresented) {
                scanSheetContent
                    .interactiveDismissDisabled()
            }
            .background(
                Gradients.purpleBg
                    .matchedGeometryEffect(id: AnimationNamespaceIds.background, in: animation)
                    .ignoresSafeArea()
            )
        }
    }

    var mainSheetContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                if likenessManager.isRegistered {
                    Text("My Rule:")
                        .h5()
                        .foregroundStyle(Gradients.purpleText)
                        .padding(.bottom, 12)
                        .matchedGeometryEffect(
                            id: AnimationNamespaceIds.extra,
                            in: animation,
                            properties: .position
                        )
                    ZStack(alignment: .topLeading) {
                        if isSuccessTooltipShown {
                            ruleTooltip
                        }
                        Button(action: { isRuleSheetPresented = true }) {
                            (
                                Text(likenessManager.rule.title) +
                                    Text(" ") +
                                    Text(Image(.arrowDownSLine))
                                    .foregroundColor(.baseBlack)
                            )
                            .additional1()
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Gradients.purpleText)
                            .frame(maxWidth: 306, alignment: .leading)
                            .matchedGeometryEffect(
                                id: AnimationNamespaceIds.subtitle,
                                in: animation,
                                properties: .position
                            )
                        }
                    }
                } else {
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
                        .fixedSize(horizontal: false, vertical: true)
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
                            id: AnimationNamespaceIds.extra,
                            in: animation,
                            properties: .position
                        )
                }
            }
            Text("AI can now replicate your face, voice, and identity without asking for your permission. But you never agreed to that, raising a fundamental question: who owns your likeness?\n\nRarimo is building the infrastructure to give you back that control. With this app, you can create a private, verifiable record that defines how your likeness can and can’t be used.\n\nYour face stays on your device. No company owns it. And over time, no AI model will be able to ignore your rule.")
                .body3()
                .foregroundStyle(.baseBlack.opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
        }
        // HACK: prevent pull to close on empty space
        .background(.white.opacity(0.01))
        .padding(.horizontal, 20)
    }

    var footer: some View {
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
                    action: { isRuleSheetPresented = true }
                )
                .controlSize(.large)
            }
        }
        .padding(20)
    }

    var scanSheetContent: some View {
        ZStack {
            if likenessManager.faceImage == nil {
                FaceLikenessView(
                    onConfirm: { image in
                        likenessManager.setFaceImage(UIImage(cgImage: image))
                    },
                    onBack: { isScanSheetPresented = false }
                )
            } else {
                LikenessProcessing<LikenessProcessingRegisterTask>(
                    onComplete: {
                        likenessManager.setIsRegistered(true)
                        isScanSheetPresented = false
                        FeedbackGenerator.shared.notify(.success)
                        showSuccessTooltip()
                    },
                    onClose: {
                        likenessManager.setFaceImage(nil)
                        isScanSheetPresented = false
                    }
                )
            }
        }
    }

    var ruleTooltip: some View {
        ZStack(alignment: .bottomLeading) {
            Text("Success! Your rule is set. You can update it anytime by clicking the title.")
                .body5()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.baseBlack, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.baseWhite)
                .frame(maxWidth: 243)
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
}

#Preview {
    LikenessView(onClose: {}, animation: Namespace().wrappedValue)
        .environmentObject(LikenessManager())
}
