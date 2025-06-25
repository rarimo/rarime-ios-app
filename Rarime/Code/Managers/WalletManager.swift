import Alamofire
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

    @Published var transactions: [Transaction] = []
    @Published var isTransactionsLoading = false
    @Published private var scanTXsNextPageParams: EvmScanTransactionNextPageParams?

    init() {
        do {
            if try AppKeychain.containsValue(.privateKey) {
                self.privateKey = try AppKeychain.getValue(.privateKey)
            }
        } catch {
            LoggerUtil.common.error("Failed to get private key: \(error.localizedDescription, privacy: .public)")
        }

        self.web3 = Web3(rpcURL: ConfigManager.shared.evm.rpcURL.absoluteString)
    }

    var hasMoreTransactions: Bool {
        return scanTXsNextPageParams != nil
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

    @MainActor
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

        let signedTx = try tx.sign(with: ethPrivateKey, chainId: .init(ConfigManager.shared.evm.chainId))
        let txHash = try web3.eth.sendRawTransaction(transaction: signedTx).wait()

        let receipt = await waitForTransactionReceipt(txHash: txHash)
        if receipt == nil {
            throw WalletError.transactionTimeout
        }

        LoggerUtil.common.info("Transfer transaction hash: \(receipt!.transactionHash.hex(), privacy: .public)")

        await loadTransactions()
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
    func loadTransactions() async {
        if isTransactionsLoading {
            return
        }

        isTransactionsLoading = true
        defer { isTransactionsLoading = false }

        scanTXsNextPageParams = nil

        do {
            transactions = try await fetchTransactions()
        } catch {
            LoggerUtil.common.error("Failed to load transactions: \(error, privacy: .public)")
            AlertManager.shared.emitError("Failed to load transactions")
        }
    }

    @MainActor
    func loadNextTransactions() async {
        if scanTXsNextPageParams == nil {
            return
        }

        do {
            try transactions.append(contentsOf: await fetchTransactions())
        } catch {
            LoggerUtil.common.error("Failed to load next transactions: \(error, privacy: .public)")
            AlertManager.shared.emitError("Failed to load transactions")
        }
    }

    @MainActor
    private func fetchTransactions() async throws -> [Transaction] {
        do {
            guard let ethereumAddress = UserManager.shared.ethereumAddress else {
                return []
            }

            let transactionResponse = try await EvmScanAPI.shared.getTransactions(ethereumAddress, scanTXsNextPageParams)

            var transactions: [Transaction] = []
            for tx in transactionResponse.items {
                let isSending = tx.from.hash.lowercased() == ethereumAddress.lowercased()

                var title: String
                if let method = tx.method {
                    title = method
                } else {
                    title = isSending ? String(localized: "Send") : String(localized: "Receive")
                }

                transactions.append(Transaction(
                    title: title,
                    icon: isSending ? .arrowUp : .arrowDown,
                    amount: EthereumQuantity(quantity: BigUInt(tx.value) ?? BigUInt(0)),
                    date: tx.date,
                    type: isSending ? .sent : .received,
                    hash: tx.hash
                ))
            }

            scanTXsNextPageParams = transactionResponse.nextPageParams
            return transactions
        } catch let error as AFError where error.isExplicitlyCancelledError {
            return []
        } catch {
            if error.asAFError?.isResponseValidationError == true {
                return []
            } else {
                throw error
            }
        }
    }

    func reset() {
        transactions = []
        isTransactionsLoading = false
        scanTXsNextPageParams = nil
    }
}
