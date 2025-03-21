import Web3
import Foundation

extension BigUInt {
    var asciiValue: String {
        let hexString = String(self, radix: 16)

        let paddedHexString = hexString.count % 2 == 0
            ? hexString
            : "0" + hexString

        guard let data = Data(hex: paddedHexString) else { return "" }

        return String(data: data, encoding: .ascii) ?? ""
    }
    
    func toHex(isFullHex: Bool = true) -> String {
        let hex = String(self, radix: 16)
        return isFullHex ? "0x" + hex : hex
    }
}
