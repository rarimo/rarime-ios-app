import SwiftUI

struct WalletSendView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    
    let onBack: () -> Void

    @State private var address = ""
    @State private var addressErrorMessage = ""

    @State private var amount = ""

    @State private var isScanning = false
    @State private var isTransfering = false
    
    @State private var cancelables: [Task<(), Never>] = []

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
            } else if isTransfering {
                ProgressView()
                    .controlSize(.large)
            } else {
                content
            }
        }
        .onDisappear(perform: cleanup)
    }

    var content: some View {
        WalletRouteLayout(
            title: String(localized: "Send RMO"),
            description: String(localized: "Withdraw the RMO token"),
            onBack: onBack
        ) {
            VStack {
                CardContainer {
                    VStack(spacing: 20) {
                        AppTextField(
                            text: $address,
                            errorMessage: $addressErrorMessage,
                            label: String(localized: "Address"),
                            placeholder: "rarimo1...",
                            action: {
                                Button(action: toggleScan) {
                                    Image(Icons.qrCode)
                                        .iconMedium()
                                        .foregroundStyle(.textSecondary)
                                }
                            }
                        )
                        AppTextField(
                            text: $amount,
                            errorMessage: .constant(""),
                            label: String(localized: "Amount"),
                            placeholder: "0.0 RMO",
                            keyboardType: .numberPad,
                            action: {
                                HStack(spacing: 16) {
                                    VerticalDivider()
                                    Button(action: {
                                        amount = String(userManager.balance)
                                    }) {
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
                                Text("\(userManager.balance.formatted()) RMO")
                                    .body4()
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                Spacer()
                footer
            }
        }
    }

    var footer: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Receiver gets")
                    .body4()
                    .foregroundStyle(.textSecondary)
                Text("\((Double(amount) ?? 0.0).formatted()) RMO")
                    .subtitle3()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            AppButton(
                text: "Send",
                width: 100,
                action: transfer
            )
            .controlSize(.large)
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(.backgroundPure)
    }
    
    func transfer() {
        isTransfering = true
        
        let createNewUserCancelable = Task { @MainActor in
            defer {
                self.isTransfering = false
            }
            
            do {
                try await userManager.sendTokens(address, amount)
                
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
                
                let balance = try await userManager.fetchBalanse()
                
                userManager.balance = Double(balance) ?? 0
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to send tokens: \(error)")
            }
        }
        
        self.cancelables.append(createNewUserCancelable)
    }
    
    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
}

#Preview {
    WalletSendView(onBack: {})
        .environmentObject(WalletManager())
        .environmentObject(UserManager.shared)
}
