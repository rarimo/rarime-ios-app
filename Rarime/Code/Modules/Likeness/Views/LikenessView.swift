import SwiftUI

struct LikenessView: View {
    let onClose: () -> Void
    var animation: Namespace.ID

    @StateObject var viewModel = LikenessViewModel()

    @State private var isRuleSheetPresented = false
    @State private var isScanSheetPresented = false
    @State private var isFaceScanned = false

    @State private var isRegistrationSuccess = false

    @State private var likenessRule: LikenessRule = .init(rawValue: AppUserDefaults.shared.likenessRule) ?? .unset {
        didSet {
            AppUserDefaults.shared.likenessRule = likenessRule.rawValue
        }
    }

    @State private var isLikenessRegistered = AppUserDefaults.shared.isLikenessRegistered {
        didSet {
            AppUserDefaults.shared.isLikenessRegistered = isLikenessRegistered
        }
    }

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
                        bottomOffset: isLikenessRegistered ? 0 : 152,
                        maxBlur: 200,
                        background: {
                            Image(.likenessFace)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.7)
                                .matchedGeometryEffect(id: AnimationNamespaceIds.image, in: animation)
                        }
                    ) {
                        mainSheetContent
                    }
                    if !isLikenessRegistered {
                        footer
                    }
                }
                .dynamicSheet(isPresented: $isRuleSheetPresented) {
                    LikenessSetRuleView(
                        rule: likenessRule,
                        onSave: { rule in
                            isRuleSheetPresented = false
                            likenessRule = rule
                            if !isLikenessRegistered {
                                isScanSheetPresented = true
                            }
                        }
                    )
                }
            }
            .sheet(isPresented: $isScanSheetPresented) {
                scanSheetContent
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
                if isLikenessRegistered {
                    Button(action: { isRuleSheetPresented = true }) {
                        (
                            Text(likenessRule.title) +
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
                            id: AnimationNamespaceIds.footer,
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
            if isFaceScanned {
                LikenessProcessing<LikenessProcessingRegisterTask>(
                    onCompletion: {
                        isRegistrationSuccess = true
                        isLikenessRegistered = true
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
    }
}

#Preview {
    LikenessView(onClose: {}, animation: Namespace().wrappedValue)
}
