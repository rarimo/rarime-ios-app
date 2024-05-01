import Foundation

extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    
    var hex: String {
        String(reduce(into: "".unicodeScalars) { result, value in
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
        })
    }
}
