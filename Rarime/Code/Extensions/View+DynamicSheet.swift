import SwiftUI

let DEFAULT_SHEET_HEIGHT: CGFloat = 300

private struct DynamicSheetHeightModifier: ViewModifier {
    let fullScreen: Bool

    @State var sheetHeight: CGFloat = DEFAULT_SHEET_HEIGHT

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo -> Color in
                DispatchQueue.main.async {
                    self.sheetHeight = geo.size.height > UIScreen.main.bounds.height
                        ? DEFAULT_SHEET_HEIGHT
                        : geo.size.height
                }
                return Color.clear
            }
        )
        .presentationDetents(fullScreen ? [.large] : [.height(sheetHeight)])
    }
}

extension View {
    private func applyPresentationCornerRadius(_ radius: CGFloat) -> some View {
        if #available(iOS 16.4, *) {
            return self.presentationCornerRadius(radius)
        } else {
            return self
        }
    }

    func dynamicSheet<Content>(
        isPresented: Binding<Bool>,
        fullScreen: Bool = false,
        title: LocalizedStringResource? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        return sheet(isPresented: isPresented) {
            ZStack(alignment: .topTrailing) {
                Color.backgroundPure.ignoresSafeArea(.container)
                VStack(spacing: 0) {
                    if let title {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(title)
                                .h6()
                                .foregroundStyle(.textPrimary)
                                .padding(.horizontal, 20)
                            HorizontalDivider()
                        }
                        .padding(.top, 20)
                    }
                    content()
                }
                .frame(maxWidth: .infinity)
                .presentationDragIndicator(.hidden)
                .applyPresentationCornerRadius(24)
                // Make sheet height dynamic
                .fixedSize(horizontal: false, vertical: !fullScreen)
                .modifier(DynamicSheetHeightModifier(fullScreen: fullScreen))
                Button(action: { isPresented.wrappedValue = false }) {
                    Image(Icons.close)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
        }
    }
}

#Preview {
    Text(String("Sheet"))
        .dynamicSheet(isPresented: .constant(true), title: LocalizedStringResource("Sheet Title", table: "preview")) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String("Lorem ipsum dolor sit amet, consectetur adipiscing elit."))
                    .body3()
                    .foregroundStyle(.textSecondary)
                AppButton(
                    text: LocalizedStringResource("Button", table: "preview"),
                    action: { print("Button pressed") }
                )
                .padding(.top, 16)
            }
            .padding(20)
        }
}
