import SwiftUI

struct WalletSendView: View {
    let onBack: () -> Void

    @State private var address = ""
    @State private var amount = ""

    var body: some View {
        WalletRouteLayout(
            title: "Send RMO",
            description: "Withdraw the RMO token",
            onBack: onBack
        ) {
            VStack {
                CardContainer {
                    VStack(spacing: 20) {
                        AppTextField(
                            text: $address,
                            errorMessage: .constant(""),
                            label: "Address",
                            placeholder: "rarimo1...",
                            action: {
                                Image(Icons.qrCode)
                                    .iconMedium()
                                    .foregroundStyle(.textSecondary)
                            }
                        ) {}
                        AppTextField(
                            text: $amount,
                            errorMessage: .constant(""),
                            label: "Amount",
                            placeholder: "0.0",
                            action: {
                                HStack(spacing: 16) {
                                    VerticalDivider()
                                    Button(action: {}) {
                                        Text("MAX")
                                            .buttonMedium()
                                            .foregroundStyle(.textSecondary)
                                    }
                                }
                                .frame(height: 20)
                            }
                        ) {
                            HStack {
                                Text("Available:")
                                    .body4()
                                    .foregroundStyle(.textSecondary)
                                Spacer()
                                Text("120.591 RMO")
                                    .body4()
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Receiver gets")
                            .body4()
                            .foregroundStyle(.textSecondary)
                        Text("0.00 RMO")
                            .subtitle3()
                            .foregroundStyle(.textPrimary)
                    }
                    Spacer()
                    AppButton(
                        text: "Send",
                        width: 100,
                        action: {}
                    )
                    .controlSize(.large)
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(.backgroundPure)
            }
        }
    }
}

#Preview {
    WalletSendView(onBack: {})
}
