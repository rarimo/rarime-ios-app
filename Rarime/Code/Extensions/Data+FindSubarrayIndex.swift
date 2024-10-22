import Foundation

extension Data {
    func findSubarrayIndex(subarray: Data) -> UInt? {
        let mainLen = self.count
        let subLen = subarray.count

        for i in 0 ... (mainLen - subLen) {
            if self[i ..< i + subLen] == subarray {
                return UInt(i)
            }
        }

        return nil
    }
}
