import SwiftUI

import PromiseKit
import Web3

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    let web3: Web3

    var privateKey: Data?

    @Published var balance: EthereumQuantity?

    init() {
        do {
            if try AppKeychain.containsValue(.privateKey) {
                self.privateKey = try AppKeychain.getValue(.passport)
            }
        } catch {
            LoggerUtil.common.error("Failed to get private key: \(error.localizedDescription, privacy: .public)")
        }

        self.web3 = Web3(rpcURL: ConfigManager.shared.api.evmRpcURL.absoluteString)
    }

    @MainActor
    func updateBalance() async throws {
        guard let privateKey else {
            return
        }

        let ethPrivateKey = try EthereumPrivateKey(privateKey: privateKey.bytes)

        balance = try web3.eth.getBalance(address: ethPrivateKey.address, block: .latest).wait()
    }
}
