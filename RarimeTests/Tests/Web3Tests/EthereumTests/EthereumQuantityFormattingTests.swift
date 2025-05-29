import BigInt
@testable import Rarime
import Web3
import XCTest

final class EthereumQuantityFormattingTests: XCTestCase {
    func testFormat_withFraction() {
        // 1.2345 ETH should show four decimals
        let wei = BigUInt("1234500000000000000")
        let qty = EthereumQuantity(quantity: wei)

        let formatted = qty.format()
        XCTAssertEqual(formatted, "1.2345",
                       "Formatting of fractional ETH values is incorrect")
    }

    func testFormat_wholeEther() {
        // 1.0 ETH should render with two decimal places
        let wei = BigUInt("1000000000000000000")
        let qty = EthereumQuantity(quantity: wei)

        let formatted = qty.format()
        XCTAssertEqual(formatted, "1.00",
                       "Whole Ether formatting is incorrect")
    }

    func testFormat_zero() {
        // Zero Wei should render as 0.00
        let wei = BigUInt(0)
        let qty = EthereumQuantity(quantity: wei)

        let formatted = qty.format()
        XCTAssertEqual(formatted, "0.00",
                       "Zero Wei formatting is incorrect")
    }

    func testFormat_roundingBehavior() {
        // 1.23456789 ETH should round to six decimal places
        let wei = BigUInt("1234567890000000000")
        let qty = EthereumQuantity(quantity: wei)

        let formatted = qty.format()
        XCTAssertEqual(formatted, "1.234568",
                       "Rounding behavior is incorrect")
    }
}
