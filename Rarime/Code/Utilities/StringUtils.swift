import Foundation
import BigInt

class StringUtils {
    static func cropString(_ input: String, lenght: Int = 10) -> String {
        return input.count > lenght * 2 ? "\(input.prefix(lenght))......\(input.suffix(lenght))" : input
    }
}
