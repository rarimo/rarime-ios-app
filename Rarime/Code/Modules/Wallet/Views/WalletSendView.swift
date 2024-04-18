import SwiftUI

struct WalletSendView: View {
    let onBack: () -> Void

    @State private var address = ""
    @State private var addressErrorMessage = ""

    @State private var amount = ""

    @State private var isScanning = false

    func toggleScan() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isScanning.toggle()
        }
    }

    var body: some View {
        ZStack {
            if isScanning {
                ScanQRView(onBack: { toggleScan() }) { result in
                    toggleScan()
                    if result.starts(with: "rarimo1") {
                        address = result
                    } else {
                        addressErrorMessage = String(localized: "Invalid Rarimo address")
                    }
                }
                .transition(.move(edge: .bottom))
            } else {
                content
            }
        }
    }

    var content: some View {
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
                            errorMessage: $addressErrorMessage,
                            label: "Address",
                            placeholder: "rarimo1...",
                            action: {
                                Button(action: toggleScan) {
                                    Image(Icons.qrCode)
                                        .iconMedium()
                                        .foregroundStyle(.textSecondary)
                                }
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
