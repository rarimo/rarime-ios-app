import Combine
import SwiftUI

import Web3

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
    @State private var isConfirmationSheetPresented = false
    
    @State private var isFeeCalculating = false
    
    @State private var fee: EthereumQuantity?
    
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
                    
                    var addressToPaste = result
                    addressToPaste = addressToPaste.replacingOccurrences(of: "ethereum:", with: "")
                    
                    if Ethereum.isValidAddress(addressToPaste) {
                        address = addressToPaste
                    } else {
                        addressErrorMessage = String(localized: "Invalid address")
                    }
                }
                .transition(.move(edge: .bottom))
            } else {
                content
            }
        }
        .onAppear(perform: calculateFee)
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
                        .disabled(isTransfering)
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
                                        amount = walletManager.displayedBalance
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
                                    .body5()
                                    .foregroundStyle(.textSecondary)
                                Spacer()
                                Text(walletManager.displayedBalance)
                                    .body5()
                                    .foregroundStyle(.textPrimary)
                            }
                        }
                        .disabled(isTransfering)
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
                    .body5()
                    .foregroundStyle(.textSecondary)
                Text(walletManager.displayedBalance)
                    .subtitle5()
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            AppButton(
                text: "Send",
                width: 100,
                action: {
                    if validateForm() {
                        isConfirmationSheetPresented = true
                    }
                }
            )
            .controlSize(.large)
            .disabled(isTransfering)
            .dynamicSheet(isPresented: $isConfirmationSheetPresented, title: "Review Transaction") {
                confirmationView
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(.bgPure)
    }
    
    var confirmationView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                ConfirmationTextRow(
                    title: String(localized: "Address"),
                    value: address
                )
                ConfirmationTextRow(
                    title: String(localized: "Amount"),
                    value: amount
                )
                ConfirmationTextRow(
                    title: String(localized: "Fee"),
                    value: "\(fee?.double ?? 0)"
                )
            }
            VStack(spacing: 4) {
                AppButton(
                    text: isTransfering ? "Sending..." : "Confirm",
                    action: transfer
                )
                .controlSize(.large)
                .disabled(isTransfering)
                AppButton(
                    variant: .quartenary,
                    text: "Cancel",
                    action: { isConfirmationSheetPresented = false }
                )
                .controlSize(.large)
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 20)
    }
    
    func validateForm() -> Bool {
        if !Ethereum.isValidAddress(address) {
            addressErrorMessage = String(localized: "Invalid address")
        }
        
        guard let amountToSend = Double(amount) else {
            amountErrorMessage = String(localized: "Invalid amount")
            
            return false
        }
        
        guard let availableBalance = Double(walletManager.displayedBalance) else {
            amountErrorMessage = String(localized: "Failed to get balance")
            
            return false
        }
        
        if availableBalance < amountToSend {
            amountErrorMessage = String(localized: "Insufficient balance")
        }
        
        if amountToSend == 0 {
            amountErrorMessage = String(localized: "Amount must be greater than 0")
        }
        
        return addressErrorMessage.isEmpty && amountErrorMessage.isEmpty
    }
    
    func transfer() {
        isTransfering = true
        
        let cancelable = Task { @MainActor in
            defer {
                isTransfering = false
            }
            
            guard let amount = Double(amount) else {
                return
            }
            
            do {
                try await walletManager.transfer(amount, address)
                
                walletManager.registerTransfer(amount)
                
                AlertManager.shared.emitSuccess("Transaction sent")
                
                onBack()
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.common.error("failed to send tokens: \(error.localizedDescription, privacy: .public)")
                
                AlertManager.shared.emitError(.unknown("Failed to send tokens"))
            }
        }
        
        cancelables.append(cancelable)
    }
    
    func calculateFee() {
        if isFeeCalculating {
            return
        }
        
        isFeeCalculating = true
        
        let cancelable = Task { @MainActor in
            defer {
                isFeeCalculating = false
            }
            
            do {
                fee = try await walletManager.getFeeForTransfer()
            } catch is CancellationError {
                return
            } catch {
                LoggerUtil.common.error("failed to send tokens: \(error.localizedDescription, privacy: .public)")
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

private struct ConfirmationTextRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title).body4()
            Spacer()
            Text(value).subtitle6()
        }
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    WalletSendView(token: WalletToken.eth, onBack: {})
        .environmentObject(UserManager())
        .environmentObject(WalletManager())
}
