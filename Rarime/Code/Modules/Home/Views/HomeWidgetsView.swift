import Alamofire
import SwiftUI

private struct WidgetWrapper {
    let widget: HomeWidget
    let card: SnapCarouselCard
}

struct HomeWidgetsView: View {
    @EnvironmentObject private var likenessManager: LikenessManager
    @EnvironmentObject private var homeViewModel: HomeView.ViewModel
    @EnvironmentObject private var hiddenKeysViewModel: HiddenKeysViewModel

    @Binding var selectedWidget: HomeWidget?
    let namespaceProvider: (HomeWidget) -> Namespace.ID

    @StateObject private var viewModel = HomeWidgetsViewModel()

    @State private var isCopied = false
    @State private var isManageSheetPresented = false

    var body: some View {
        ZStack(alignment: .trailing) {
            SnapCarouselView(
                index: $homeViewModel.currentWidgetIndex,
                cards: visibleWidgets.map { $0.card },
                spacing: 30,
                trailingSpace: 20,
                bottomContentHeight: 56
            ) {
                AppButton(
                    text: "Manage widgets",
                    leftIcon: .filter3Line,
                    width: 160,
                    action: { isManageSheetPresented = true }
                )
                .controlSize(.large)
            }
            .disabled(selectedWidget != nil)
            .padding(.horizontal, 22)
            VerticalStepIndicator(
                steps: visibleWidgets.count,
                currentStep: homeViewModel.currentWidgetIndex
            )
            .padding(.trailing, 8)
        }
        .dynamicSheet(isPresented: $isManageSheetPresented) {
            ManageWidgetsView(
                selectedWidgets: viewModel.widgets,
                onAdd: { widget in
                    viewModel.addWidget(widget)
                    homeViewModel.currentWidgetIndex = visibleWidgets.count
                },
                onRemove: { widget in
                    viewModel.removeWidget(widget)
                    homeViewModel.currentWidgetIndex = visibleWidgets.count
                }
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
        .filter { $0.widget.isVisible }
        .filter { $0.widget != .earn || homeViewModel.hasBalance }
        .filter { viewModel.widgets.contains($0.widget) }
    }

    private var earnWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .earn,
            card: SnapCarouselCard(
                disabled: homeViewModel.isBalanceFetching || homeViewModel.pointsBalance == nil,
                action: { selectedWidget = .earn }
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
                        Text("Complete various tasks and get rewarded with Rarimo tokens")
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
            card: SnapCarouselCard(action: { selectedWidget = .freedomTool }) {
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
                disabled: hiddenKeysViewModel.user == nil || hiddenKeysViewModel.user?.celebrity.status == .maintenance,
                action: { selectedWidget = .hiddenKeys }
            ) {
                HomeCardView(
                    foregroundGradient: Gradients.purpleText,
                    foregroundColor: .invertedDark,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.hiddenKeysBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: "Hidden keys",
                    subtitle: "Find a face",
                    topContent: {
                        HiddenKeysStatusChip(status: hiddenKeysViewModel.user?.celebrity.status ?? .maintenance)
                    },
                    animation: namespaceProvider(.hiddenKeys)
                )
            }
        )
    }

    private var recoveryWidget: WidgetWrapper {
        WidgetWrapper(
            widget: .recovery,
            card: SnapCarouselCard(action: { selectedWidget = .recovery }) {
                HomeCardView(
                    foregroundGradient: Gradients.greenText,
                    foregroundColor: .invertedDark,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.recoveryBg)
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
                action: { selectedWidget = .likeness }
            ) {
                HomeCardView(
                    foregroundGradient: Gradients.limeText,
                    foregroundColor: .invertedDark,
                    topIcon: .rarime,
                    bottomIcon: .arrowRightUpLine,
                    imageContent: {
                        Image(.likenessBg)
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    },
                    title: likenessManager.isRegistered ? nil : "Digital likeness",
                    subtitle: likenessManager.isRegistered ? nil : "Set a rule",
                    bottomContent: {
                        if likenessManager.isRegistered {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("My Rule:")
                                    .subtitle5()
                                    .foregroundStyle(.textPrimary)
                                    .padding(.bottom, 8)
                                Text(likenessManager.rule.title)
                                    .additional1()
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Gradients.limeText)
                                    .frame(maxWidth: 306, alignment: .leading)
                            }
                        } else {
                            Text("Your data, your rules")
                                .body4()
                                .foregroundStyle(.baseBlack.opacity(0.5))
                                .padding(.top, 12)
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
        selectedWidget: Binding<HomeWidget?>(
            get: { nil },
            set: { _ in }
        ),
        namespaceProvider: { _ in Namespace().wrappedValue }
    )
    .environmentObject(LikenessManager())
    .environmentObject(HomeView.ViewModel())
    .environmentObject(HiddenKeysViewModel())
}
