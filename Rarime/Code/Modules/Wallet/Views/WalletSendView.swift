import SwiftUI
import Combine

struct WalletSendView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    
    let onBack: () -> Void

    @State private var address = ""
    @State private var addressErrorMessage = ""

    @State private var amount = ""
    @State private var amountErrorMessage = ""

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
                            errorMessage: $amountErrorMessage,
                            label: String(localized: "Amount"),
                            placeholder: "0.0 RMO",
                            keyboardType: .decimalPad,
                            action: {
                                HStack(spacing: 16) {
                                    VerticalDivider()
                                    Button(action: {
                                        amount = String(userManager.balance / Double(Rarimo.rarimoTokenMantis))
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
                                Text("\((userManager.balance / Double(Rarimo.rarimoTokenMantis)).formatted()) RMO")
                                    .body4()
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                        .onReceive(Just(amount), perform: handleAmountOnReceive)
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
        
        let cancelable = Task { @MainActor in
            defer {
                self.isTransfering = false
            }
            
            do {
                if !RarimoUtils.isValidAddress(address) {
                    addressErrorMessage = String(localized: "Invalid Rarimo address")
                    return
                }
                
                let amountToSend = (Double(amount) ?? 0) * Double(Rarimo.rarimoTokenMantis)
                let amountToSendRaw = Int(amountToSend.rounded())
                
                if userManager.balance < amountToSend {
                    amountErrorMessage = String(localized: "Insufficient balance")
                    return
                }
                
                if amountToSend == 0 {
                    amountErrorMessage = String(localized: "Amount must be greater than 0")
                    
                    return
                }
                
                let _ = try await userManager.sendTokens(address, amountToSendRaw.description)
                
                self.walletManager.transfer(Double(amount) ?? 0)
                
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                
                onBack()
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to send tokens: \(error.localizedDescription, privacy: .public)")
            }
        }
        
        self.cancelables.append(cancelable)
    }
    
    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
    
    func handleAmountOnReceive(_ newValue: String) {
        let filtered = newValue.filter { "0123456789,.".contains($0) }
        if filtered != newValue {
            self.amount = filtered
        }
        
        if filtered.contains(",") {
            self.amount = filtered.replacingOccurrences(of: ",", with: ".")
        }
    }
}

#Preview {
    WalletSendView(onBack: {})
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
}
