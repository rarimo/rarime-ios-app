import Combine
import SwiftUI

struct WalletSendView: View {
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var userManager: UserManager
    
    let token: WalletToken
    let onBack: () -> Void

    @State private var address = ""
    @State private var addressErrorMessage = ""

    @State private var amount = ""
    @State private var amountErrorMessage = ""

    @State private var isScanning = false
    @State private var isTransfering = false
    
    @State private var cancelables: [Task<Void, Never>] = []

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
                    // TODO: validate according to the token type
                    if RarimoUtils.isValidAddress(result) {
                        address = result
                    } else {
                        addressErrorMessage = String(localized: "Invalid address")
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
            title: String(localized: "Send \(token.rawValue)"),
            description: String(localized: "Withdraw the \(token.rawValue) token"),
            onBack: onBack
        ) {
            VStack {
                CardContainer {
                    VStack(spacing: 20) {
                        AppTextField(
                            text: $address,
                            errorMessage: $addressErrorMessage,
                            label: String(localized: "Address"),
                            placeholder: "Long press to paste",
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
                            placeholder: "0.0 \(token.rawValue)",
                            keyboardType: .decimalPad,
                            action: {
                                HStack(spacing: 16) {
                                    VerticalDivider()
                                    Button(action: {
                                        // TODO: use balance according to the token type
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
                                // TODO: use balance according to the token type
                                Text(try! String("\((userManager.balance / Double(Rarimo.rarimoTokenMantis)).formatted()) \(token.rawValue)"))
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
                Text(try! String("\((Double(amount) ?? 0.0).formatted()) \(token.rawValue)"))
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
                isTransfering = false
            }
            
            do {
                // TODO: validate according to the token type
                if !RarimoUtils.isValidAddress(address) {
                    addressErrorMessage = String(localized: "Invalid address")
                    return
                }
                
                // TODO: calculate according to the token type
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
                
                walletManager.transfer(Double(amount) ?? 0)
                
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                
                onBack()
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.intro.error("failed to send tokens: \(error.localizedDescription, privacy: .public)")
            }
        }
        
        cancelables.append(cancelable)
    }
    
    func cleanup() {
        for cancelable in cancelables {
            cancelable.cancel()
        }
    }
    
    func handleAmountOnReceive(_ newValue: String) {
        let filtered = newValue.filter { "0123456789,.".contains($0) }
        if filtered != newValue {
            amount = filtered
        }
        
        if filtered.contains(",") {
            amount = filtered.replacingOccurrences(of: ",", with: ".")
        }
    }
}

#Preview {
    WalletSendView(token: WalletToken.rmo, onBack: {})
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
}
