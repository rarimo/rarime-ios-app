import SwiftUI

import PromiseKit
import Web3

enum WalletError: Error, LocalizedError {
    case transactionTimeout

    var errorDescription: String? {
        switch self {
        case .transactionTimeout:
            return String(localized: "Transaction timed out")
        }
    }
}

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    let web3: Web3

    var privateKey: Data?

    @Published var balance: EthereumQuantity?
    @Published var isBalanceLoading = false

    @Published var transactions: [Transaction] {
        didSet {
            AppUserDefaults.shared.walletTransactions = transactions.json
        }
    }

    @Published var isTransactionsLoading = false

    @Published var scanTransactions: [EvmScanTransactionItem] = []

    var nextPageParams: EvmScanTransactionNextPageParams?

    init() {
        do {
            if try AppKeychain.containsValue(.privateKey) {
                self.privateKey = try AppKeychain.getValue(.privateKey)
            }
        } catch {
            LoggerUtil.common.error("Failed to get private key: \(error.localizedDescription, privacy: .public)")
        }

        self.transactions = AppUserDefaults.shared.walletTransactions.isEmpty
            ? []
            : try! JSONDecoder().decode([Transaction].self, from: AppUserDefaults.shared.walletTransactions)

        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
    }

    var displayedBalance: String {
        guard let balance else {
            return "0.00"
        }

        return balance.format()
    }

    @MainActor
    func updateBalance() async throws {
        if isBalanceLoading { return }
        guard let privateKey else { return }

        isBalanceLoading = true
        defer { isBalanceLoading = false }

        let ethPrivateKey = try EthereumPrivateKey(privateKey: privateKey.bytes)
        balance = try await web3.eth.getBalanceAsync(address: ethPrivateKey.address, block: .latest)
    }

    func getFeeForTransfer() async throws -> EthereumQuantity {
        let gasPrice = try web3.eth.gasPrice().wait()
        let fee = (gasPrice.quantity * 2) * 21_000
        return .init(quantity: fee)
    }

    func transfer(
        _ amount: Decimal,
        _ to: String
    ) async throws {
        guard let privateKey else {
            return
        }

        let amountToTransfer = EthereumQuantity(decimal: amount)
        let ethPrivateKey = try EthereumPrivateKey(privateKey: privateKey.bytes)
        let nonce = try web3.eth.getTransactionCount(address: ethPrivateKey.address, block: .latest).wait()

        var gasPrice = try web3.eth.gasPrice().wait()
        gasPrice = EthereumQuantity(quantity: gasPrice.quantity * 2)

        let tx = try EthereumTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: 21_000,
            from: ethPrivateKey.address,
            to: EthereumAddress(hex: to, eip55: false),
            value: amountToTransfer
        )

        let signedTx = try tx.sign(with: ethPrivateKey, chainId: .init(ConfigManager.shared.api.evmChainId))
        let txHash = try web3.eth.sendRawTransaction(transaction: signedTx).wait()

        let receipt = await waitForTransactionReceipt(txHash: txHash)
        if receipt == nil {
            throw WalletError.transactionTimeout
        }

        LoggerUtil.common.info("Transfer transaction hash: \(receipt!.transactionHash.hex(), privacy: .public)")
    }

    func waitForTransactionReceipt(txHash: EthereumData, timeout: TimeInterval = 60) async -> EthereumTransactionReceiptObject? {
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            let receipt = try? web3.eth.getTransactionReceipt(transactionHash: txHash).wait()
            if receipt != nil {
                return receipt
            }

            try? await Task.sleep(for: .seconds(2))
        }

        return nil
    }

    @MainActor
    func registerTransfer(_ amount: Double) {
        transactions.append(
            Transaction(
                title: String(localized: "Send"),
                icon: Icons.arrowUp,
                amount: amount,
                date: Date(),
                type: .sent
            )
        )
    }

    func pullTransactions() async throws {
        isTransactionsLoading = true
        defer { isTransactionsLoading = false }

        guard let ethereumAddress = UserManager.shared.ethereumAddress else {
            return
        }

        let transactionResponse = try await EvmScanAPI.shared.getTransactions(ethereumAddress, nextPageParams)

        scanTransactions.append(contentsOf: transactionResponse.items)

        nextPageParams = transactionResponse.nextPageParams
    }

    func reset() {
        transactions = []
    }
}
