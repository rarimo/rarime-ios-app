import CryptoKit
import Foundation

class HMACUtils {
    static func hmacSha256(_ data: Data, _ key: Data) -> Data {
        let symmetricKey = SymmetricKey(data: key)
        
        return Data(HMAC<SHA256>.authenticationCode(for: data, using: symmetricKey))
    }
}
