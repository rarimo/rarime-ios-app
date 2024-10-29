import Foundation
import OpenSSL

class BN: Codable {
    var bn: OpaquePointer!
    
    init(_ int: UInt) {
        bn = BN_new()
        BN_set_word(bn, UInt(int))
    }
    
    init(_ bn: OpaquePointer!) {
        self.bn = bn
    }
    
    init(_ data: Data) {
        var bytes = data.bytes
        
        bn = BN_bin2bn(&bytes, Int32(data.count), nil)
    }
    
    init(hex: String) throws {
        var hex = hex
        if hex.hasPrefix("0x") {
            hex.removeFirst(2)
        }
        
        bn = BN_new()
        let charNum = BN_hex2bn(&bn, hex)
        if charNum == 0 {
            throw "Failed to convert hex to BN"
        }
    }
    
    init(dec: String) throws {
        bn = BN_new()
        let charNum = BN_dec2bn(&bn, dec)
        if charNum == 0 {
            throw "Failed to convert dec to BN"
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dec = try container.decode(String.self)
        
        bn = BN_new()
        let charNum = BN_dec2bn(&bn, dec)
        if charNum == 0 {
            throw "Failed to convert dec to BN"
        }
    }
    
    deinit {
        BN_free(bn)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension BN: CustomStringConvertible {
    var description: String {
        return dec()
    }
}

extension BN {
    func add(_ other: BN) -> BN {
        let result = BN_new()
        BN_add(result, bn, other.bn)
        
        return BN(result)
    }
    
    func sub(_ other: BN) -> BN {
        let result = BN_new()
        BN_sub(result, bn, other.bn)
        
        return BN(result)
    }
    
    func mul(_ other: BN) -> BN {
        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }
        
        let result = BN_new()
        BN_mul(result, bn, other.bn, ctx)
        
        return BN(result)
    }
    
    func div(_ other: BN) -> BN {
        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }
        
        let result = BN_new()
        BN_div(result, nil, bn, other.bn, ctx)
        
        return BN(result)
    }
    
    func mod(_ other: BN) -> BN {
        let ctx = BN_CTX_new()
        defer { BN_CTX_free(ctx) }
        
        let result = BN_new()
        BN_div(nil, result, bn, other.bn, ctx)
        
        return BN(result)
    }
    
    func lshift(_ n: Int) -> BN {
        let result = BN_new()
        BN_lshift(result, bn, Int32(n))
        
        return BN(result)
    }
    
    func rshift(_ n: Int) -> BN {
        let result = BN_new()
        BN_rshift(result, bn, Int32(n))
        
        return BN(result)
    }
    
    /// cmp returns -1 if a < b, 0 if a == b and 1 if a > b.
    func cmp(_ other: BN) -> Int32 {
        return BN_cmp(bn, other.bn)
    }
}

extension BN {
    func data(capacity: Int = 0) -> Data {
        let bits = BN_num_bits(bn)
        
        var bytes = [UInt8](repeating: 0, count: Int((bits + 7) / 8))
        _ = BN_bn2bin(bn, &bytes)
        
        var result = Data(bytes)
        
        if capacity != 0 {
            result = Data(repeating: 0, count: capacity - result.count) + result
        }
        
        return result
    }
    
    func hex() -> String {
        let hex = BN_bn2hex(bn)
        defer {
            free(hex)
        }
        
        return String(cString: hex!)
    }
    
    func fullHex() -> String {
        return "0x" + hex()
    }
    
    func dec() -> String {
        let dec = BN_bn2dec(bn)
        defer {
            free(dec)
        }
        
        return String(cString: dec!)
    }
}
