import SwiftUI

struct ManageWidgetsView: View {
    let selectedWidgets: [HomeWidget]
    let onAdd: (HomeWidget) -> Void
    let onRemove: (HomeWidget) -> Void

    @State private var widgetIndex: Int = 0

    private var manageableWidgets: [HomeWidget] {
        HomeWidget.allCases.filter { $0.isManageable }
    }

    private var highlightedWidget: HomeWidget {
        manageableWidgets[widgetIndex]
    }

    private var isWidgetSelected: Bool {
        selectedWidgets.contains(highlightedWidget)
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Manage widgets")
                .h3()
                .foregroundStyle(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            TabView(selection: $widgetIndex) {
                ForEach(manageableWidgets.indices, id: \.self) { index in
                    WidgetItemView(widget: manageableWidgets[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: widgetIndex)
            .frame(height: 420)
            HorizontalStepIndicator(
                steps: manageableWidgets.count,
                currentStep: widgetIndex
            )
            .animation(.easeInOut(duration: 0.25), value: widgetIndex)
            AppButton(
                variant: isWidgetSelected ? .secondary : .primary,
                text: isWidgetSelected ? "Remove" : "Add",
                action: {
                    FeedbackGenerator.shared.impact(.light)
                    if isWidgetSelected {
                        onRemove(highlightedWidget)
                    } else {
                        onAdd(highlightedWidget)
                    }
                }
            )
            .controlSize(.large)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }
}

private struct WidgetItemView: View {
    let widget: HomeWidget

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(widget.image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 192, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 8)
            }
            .padding(.vertical, 32)
            VStack(spacing: 12) {
                Text(widget.title)
                    .h3()
                    .foregroundStyle(.textPrimary)
                Text(widget.description)
                    .body3()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textSecondary)
                    .frame(height: 68, alignment: .top)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ManageWidgetsView(
        selectedWidgets: [.hiddenKeys, .recovery],
        onAdd: { _ in },
        onRemove: { _ in }
    )
}
