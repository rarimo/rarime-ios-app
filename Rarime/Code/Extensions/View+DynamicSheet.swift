//
//  View+DynamicSheet.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 30.03.2024.
//

import SwiftUI

let DEFAULT_SHEET_HEIGHT: CGFloat = 300

private struct DynamicSheetHeightModifier: ViewModifier {
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
        .presentationDetents([.height(sheetHeight)])
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
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        return sheet(isPresented: isPresented) {
            ZStack(alignment: .topTrailing) {
                Color.backgroundPure.ignoresSafeArea(.container)
                Button(action: { isPresented.wrappedValue = false }) {
                    Image(Icons.close)
                        .iconMedium()
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                VStack {
                    content()
                }
                .padding(.top, 32)
                .padding(.bottom, 4)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                // Make sheet height dynamic
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .modifier(DynamicSheetHeightModifier())
                .presentationDragIndicator(.hidden)
                .applyPresentationCornerRadius(24)
            }
        }
    }
}

#Preview {
    Text(String("Sheet"))
        .dynamicSheet(isPresented: .constant(true)) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String("Sheet Title"))
                    .h5()
                    .foregroundStyle(.textPrimary)
                Text(String("Lorem ipsum dolor sit amet, consectetur adipiscing elit."))
                    .body3()
                    .foregroundStyle(.textSecondary)
                Button(action: { print("Button pressed") }) {
                    Text(String("Button"))
                        .buttonMedium()
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 16)
                .buttonStyle(PrimaryContainedButtonStyle())
            }
        }
}
