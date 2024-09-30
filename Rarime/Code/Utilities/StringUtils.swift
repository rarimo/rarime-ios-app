import Foundation
import BigInt

class StringUtils {
    static func cropMiddle(_ input: String, partLength: Int = 8) -> String {
        return input.count > partLength * 2 ? "\(input.prefix(partLength))...\(input.suffix(partLength))" : input
    }
}
