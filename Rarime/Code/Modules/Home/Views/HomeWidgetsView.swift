import Alamofire
import SwiftUI

private struct WidgetWrapper {
    let widget: HomeWidget
    let card: SnapCarouselCard
}

struct HomeWidgetsView: View {
    @EnvironmentObject private var likenessManager: LikenessManager
    @EnvironmentObject private var homeViewModel: HomeView.ViewModel
    @EnvironmentObject private var findFaceViewModel: FindFaceViewModel

    let namespaceProvider: (HomeWidget) -> Namespace.ID
    let onSelect: (HomeWidget) -> Void

    @StateObject private var viewModel = HomeWidgetsViewModel()

    @State private var currentIndex: Int = 0
    @State private var isCopied = false
    @State private var isManageSheetPresented = false

    var body: some View {
        ZStack(alignment: .trailing) {
            SnapCarouselView(
                index: $currentIndex,
                cards: visibleWidgets.map { $0.card },
                spacing: 30,
                trailingSpace: 20,
                bottomContentHeight: 56
            ) {
                AppButton(
                    text: "Manage widgets",
                    width: 160,
                    action: { isManageSheetPresented = true }
                )
                .controlSize(.large)
            }
            .padding(.horizontal, 22)
            VerticalStepIndicator(
                steps: visibleWidgets.count,
                currentStep: currentIndex
            )
            .padding(.trailing, 8)
        }
        .dynamicSheet(isPresented: $isManageSheetPresented) {
            ManageWidgetsView(
                selectedWidgets: viewModel.widgets,
                onAdd: viewModel.addWidget,
                onRemove: viewModel.removeWidget
            )
            .padding(.top, 18)
        }
    }

    private var visibleWidgets: [WidgetWrapper] {
        [
            earnWidget,
            freedomToolWidget,
            hiddenKeysWidget,
            recoveryWidget,
            likenessWidget,
        ]
        .filter { viewModel.widgets.contains($0.widget) }
    }

    private var earnWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .earn,
            card: SnapCarouselCard(
                disabled: homeViewModel.isBalanceFetching || homeViewModel.pointsBalance == nil,
                action: { onSelect(.earn) }
            ) {
                HomeCardView(
                    foregroundGradient: Gradients.darkerGreenText,
                    foregroundColor: .invertedDark,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.earnBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Earn",
                    subtitle: "RMO",
                    bottomContent: {
                        Text("Complete various tasks and get rewarded with Rarimo tokens.")
                            .body4()
                            .foregroundStyle(.textSecondary)
                            .frame(maxWidth: 220, alignment: .leading)
                            .padding(.top, 12)
                    },
                    animation: namespaceProvider(.earn)
                )
            }
        )
    }

    private var freedomToolWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .freedomTool,
            card: SnapCarouselCard(action: { onSelect(.freedomTool) }) {
                HomeCardView(
                    foregroundGradient: Gradients.darkGreenText,
                    foregroundColor: .invertedDark,
                    topIcon: .freedomtool,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.freedomtoolBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Freedomtool",
                    subtitle: "Voting",
                    animation: namespaceProvider(.freedomTool)
                )
            }
        )
    }

    private var hiddenKeysWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .hiddenKeys,
            card: SnapCarouselCard(
                disabled: findFaceViewModel.user == nil || findFaceViewModel.user?.celebrity.status == .maintenance,
                action: { onSelect(.hiddenKeys) }
            ) {
                HomeCardView(
                    foregroundGradient: Gradients.purpleText,
                    foregroundColor: .invertedDark,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.findFaceBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Hidden keys",
                    subtitle: "Find a face",
                    topContent: {
                        FindFaceStatusChip(status: findFaceViewModel.user?.celebrity.status ?? .maintenance)
                    },
                    animation: namespaceProvider(.hiddenKeys)
                )
            }
        )
    }

    private var recoveryWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .recovery,
            card: SnapCarouselCard(action: { onSelect(.recovery) }) {
                HomeCardView(
                    foregroundGradient: Gradients.greenText,
                    foregroundColor: .invertedDark,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.recoveryShieldBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Recovery",
                    subtitle: "Method",
                    bottomContent: {
                        Text("Set up a new way to recover your account")
                            .body4()
                            .foregroundStyle(.textSecondary)
                            .frame(maxWidth: 220, alignment: .leading)
                            .padding(.top, 12)
                    },
                    animation: namespaceProvider(.recovery)
                )
            }
        )
    }

    private var likenessWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .likeness,
            card: SnapCarouselCard(
                disabled: likenessManager.isLoading,
                action: { onSelect(.likeness) }
            ) {
                HomeCardView(
                    backgroundGradient: Gradients.purpleBg,
                    foregroundGradient: Gradients.purpleText,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        if let faceImage = likenessManager.faceImage {
                            LikenessFaceImageView(image: faceImage)
                                .padding(.top, 80)
                        } else {
                            Image(.likenessFace)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.75)
                        }
                    },
                    title: likenessManager.isRegistered ? nil : "Digital likeness",
                    subtitle: likenessManager.isRegistered ? nil : "Set a rule",
                    bottomContent: {
                        if likenessManager.isRegistered {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("My Rule:")
                                    .h5()
                                    .foregroundStyle(Gradients.purpleText)
                                    .padding(.bottom, 12)
                                    .matchedGeometryEffect(
                                        id: AnimationNamespaceIds.extra,
                                        in: namespaceProvider(.likeness),
                                        properties: .position
                                    )
                                Text(likenessManager.rule.title)
                                    .additional1()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Gradients.purpleText)
                                    .frame(maxWidth: 306, alignment: .leading)
                                    .matchedGeometryEffect(
                                        id: AnimationNamespaceIds.subtitle,
                                        in: namespaceProvider(.likeness),
                                        properties: .position
                                    )
                            }
                        } else {
                            Text("First human-AI Contract")
                                .body4()
                                .foregroundStyle(.baseBlack.opacity(0.5))
                                .padding(.top, 12)
                                .matchedGeometryEffect(
                                    id: AnimationNamespaceIds.extra,
                                    in: namespaceProvider(.likeness),
                                    properties: .position
                                )
                        }
                    },
                    animation: namespaceProvider(.likeness)
                )
            }
        )
    }
}

#Preview {
    HomeWidgetsView(
        namespaceProvider: { _ in Namespace().wrappedValue },
        onSelect: { _ in }
    )
    .environmentObject(LikenessManager())
    .environmentObject(HomeView.ViewModel())
    .environmentObject(FindFaceViewModel())
}
