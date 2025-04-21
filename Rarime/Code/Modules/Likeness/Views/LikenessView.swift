import SwiftUI

struct LikenessView: View {
    let onClose: () -> Void
    var animation: Namespace.ID

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
                        bottomOffset: 130,
                        maxBlur: 200,
                        hideDragIndicator: true,
                        background: {
                            Image(.likenessFace)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 262)
                                .padding(.top, 40)
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
                                Text(RULES_SET_COUNT.formatted())
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
                                action: {}
                            )
                            .controlSize(.large)
                        }
                    }
                    .padding([.horizontal, .bottom], 20)
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

#Preview {
    LikenessView(onClose: {}, animation: Namespace().wrappedValue)
}
