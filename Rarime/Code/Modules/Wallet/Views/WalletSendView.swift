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
    @State private var isConfirmationSheetPresented = false
    
    @State private var cancelables: [Task<Void, Never>] = []
    
    private var amountToSend: Double {
        return (Double(amount) ?? 0) * Double(Rarimo.rarimoTokenMantis)
    }
    
    // TODO: calculate according to the token type
    private var fee: Double {
        return 0
    }

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
                                Text(verbatim: "\(RarimoUtils.formatBalance(userManager.balance)) \(token.rawValue)")
                                    .body4()
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
                    .body4()
                    .foregroundStyle(.textSecondary)
                Text(verbatim: "\(RarimoUtils.formatBalance(amountToSend)) \(token.rawValue)")
                    .subtitle3()
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
        .background(.backgroundPure)
    }
    
    var confirmationView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                ConfirmationTextRow(
                    title: String(localized: "Address"),
                    value: RarimoUtils.formatAddress(address)
                )
                ConfirmationTextRow(
                    title: String(localized: "Amount"),
                    value: "\(RarimoUtils.formatBalance(amountToSend)) \(token.rawValue)"
                )
                ConfirmationTextRow(
                    title: String(localized: "Fee"),
                    value: "\(fee.formatted()) \(token.rawValue)"
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
                    variant: .tertiary,
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
        // TODO: validate according to the token type
        if !RarimoUtils.isValidAddress(address) {
            addressErrorMessage = String(localized: "Invalid address")
        }
        
        // TODO: calculate according to the token type
        if userManager.balance < amountToSend {
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
            
            do {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 3)
                // TODO: calculate according to the token type
                let amountToSendRaw = Int(amountToSend.rounded())
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

private struct ConfirmationTextRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title).body3()
            Spacer()
            Text(value).subtitle4()
        }
        .foregroundStyle(.textPrimary)
    }
}

#Preview {
    WalletSendView(token: WalletToken.rmo, onBack: {})
        .environmentObject(WalletManager())
        .environmentObject(UserManager())
}
