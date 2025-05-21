import SwiftUI

import PromiseKit
import Web3

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    let web3: Web3

    var privateKey: Data?

    @Published var balance: EthereumQuantity?

    @Published var transactions: [Transaction] {
        didSet {
            AppUserDefaults.shared.walletTransactions = transactions.json
        }
    }

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

    var dispayableBalance: String {
        guard let balance else {
            return "0.00"
        }

        return balance.double.description
    }

    @MainActor
    func updateBalance() async throws {
        guard let privateKey else {
            return
        }

        let ethPrivateKey = try EthereumPrivateKey(privateKey: privateKey.bytes)

        balance = try web3.eth.getBalance(address: ethPrivateKey.address, block: .latest).wait()
    }

    func getFeeForTransfer() async throws -> EthereumQuantity {
        let gasPrice = try web3.eth.gasPrice().wait()

        let fee = (gasPrice.quantity + (gasPrice.quantity / 5)) * 21_000

        return .init(quantity: fee)
    }

    func transfer(
        _ amount: Double,
        _ to: String
    ) async throws {
        guard let privateKey else {
            return
        }

        let amountToTransfer = EthereumQuantity(amount)

        let ethPrivateKey = try EthereumPrivateKey(privateKey: privateKey.bytes)

        let nonce = try web3.eth.getTransactionCount(address: ethPrivateKey.address, block: .latest).wait()

        var gasPrice = try web3.eth.gasPrice().wait()
        gasPrice = EthereumQuantity(quantity: gasPrice.quantity + (gasPrice.quantity / 5))

        let tx = try EthereumTransaction(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: 21_000,
            from: ethPrivateKey.address,
            to: EthereumAddress(hex: to, eip55: true),
            value: amountToTransfer
        )

        let signedTx = try tx.sign(with: ethPrivateKey, chainId: .init(ConfigManager.shared.api.evmChainId))

        let txHash = try web3.eth.sendRawTransaction(transaction: signedTx).wait()

        LoggerUtil.common.debug("Transaction hash: \(txHash.hex(), privacy: .public)")
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

    func reset() {
        transactions = []
    }
}
