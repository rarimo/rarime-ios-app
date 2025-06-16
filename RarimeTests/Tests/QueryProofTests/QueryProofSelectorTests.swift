import BigInt
@testable import Rarime
import XCTest

final class QueryProofSelectorTests: XCTestCase {
    func testDefaultEnabledFields_isEmpty() {
        let selector = QueryProofSelector()
        XCTAssertTrue(selector.enabledFields.isEmpty,
                      "By default (mask = 0) there should be no enabled fields")
    }
    
    func testEnabledFields_withSingleBitMask_returnsCorrectField() {
        // mask with only bit 3 set → should enable .name
        let mask = BigUInt(1) << 3
        let selector = QueryProofSelector(mask: mask)
        
        let fields = selector.enabledFields
        XCTAssertEqual(fields, [.name],
                       "Mask with only bit 3 should enable only the `name` field")
    }
    
    func testEnabledFields_withMultipleBitsMask_returnsAllInOrder() {
        // bits 0 (nullifier), 5 (citizenship), 17 (verifyCitizenshipBlacklist)
        let mask = (BigUInt(1) << 0)
            | (BigUInt(1) << 5)
            | (BigUInt(1) << 17)
        let selector = QueryProofSelector(mask: mask)
        
        let fields = selector.enabledFields
        XCTAssertEqual(fields, [
            .nullifier,
            .citizenship,
            .verifyCitizenshipBlacklist
        ], "Should list enabled fields in ascending rawValue order")
    }
    
    func testEnabledFields_withSingleDecimalStringMask_returnsCorrectBits() {
        // hex "0x9A01" → decimal 35361 → bits 0, 5, 9, 11, and 15
        let selector = QueryProofSelector(decimalString: "35361")
        
        let fields = selector.enabledFields
        XCTAssertEqual(fields, [
            .nullifier, // bit 0
            .citizenship, // bit 5
            .timestampUpperbound, // bit 9
            .identityCounterUpperbound, // bit 11
            .birthDateUpperbound // bit 15
        ], "Decimal init should parse 35361 as mask with bits 0,5,9,11,15")
    }
    
    func testEnabledFields_withHexInit_parsesCorrectBits() {
        // hex "0x9A01" → decimal 39425 → bits 0, 9, 11, 12, and 15
        let selector = QueryProofSelector(hex: "0x9A01")
        
        let fields = selector.enabledFields
        XCTAssertEqual(fields, [
            .nullifier, // bit 0
            .timestampUpperbound, // bit 9
            .identityCounterUpperbound, // bit 11
            .passportExpirationLowerbound, // bit 12
            .birthDateUpperbound // bit 15
        ], "Hex init should parse 0x9A01 as mask with bits 0,9,11,12,15")
    }
}
