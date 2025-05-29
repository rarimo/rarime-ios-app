import BigInt
@testable import Rarime
import Web3
import XCTest

final class EthereumQuantityDecimalTests: XCTestCase {
    func testDecimal_fractionalValue() {
        // 1.2345 ETH → Wei = 1234500000000000000
        let wei = BigUInt("1234500000000000000")
        let qty = EthereumQuantity(quantity: wei)

        let dec = qty.decimal
        XCTAssertEqual(dec, Decimal(string: "1.2345")!,
                       "decimal property should convert Wei to correct Decimal ETH representation")
    }

    func testDecimal_wholeEther() {
        // 1 ETH → Wei = 1000000000000000000
        let wei = BigUInt("1000000000000000000")
        let qty = EthereumQuantity(quantity: wei)

        let dec = qty.decimal
        XCTAssertEqual(dec, Decimal(1),
                       "decimal property should produce 1 for whole Ether")
    }

    func testInitDecimal_fractionalValue() {
        // Initialize from Decimal 1.2345 → Wei = 1234500000000000000
        let dec = Decimal(string: "1.2345")!
        let qty = EthereumQuantity(decimal: dec)

        let expectedWei = BigUInt("1234500000000000000")
        XCTAssertEqual(qty.quantity, expectedWei,
                       "init(decimal:) should convert Decimal ETH to exact Wei quantity")
    }

    func testRoundTrip_decimal() {
        // Various Decimal values round-trip through decimal property exactly
        let values: [Decimal] = [
            Decimal(0),
            Decimal(1),
            Decimal(string: "0.000001")!,
            Decimal(string: "42.424242")!,
            Decimal(string: "123456.7891011")!
        ]
        for original in values {
            let qty = EthereumQuantity(decimal: original)
            let back = qty.decimal
            XCTAssertEqual(back, original,
                           "Decimal round-trip should be lossless for \(original)")
        }
    }

    func testInitDecimal_zero() {
        // Zero value edge case
        let dec = Decimal(0)
        let qty = EthereumQuantity(decimal: dec)

        XCTAssertEqual(qty.quantity, BigUInt(0),
                       "init(decimal: 0) should produce zero Wei quantity")
        XCTAssertEqual(qty.decimal, Decimal(0),
                       "decimal property of zero quantity should be 0")
    }
}
