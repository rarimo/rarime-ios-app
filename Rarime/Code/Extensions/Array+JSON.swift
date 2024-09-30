import Foundation

extension Array where Element == String {
    func toJSON() -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return jsonData
        } catch {
            print("Error encoding array to JSON: \(error)")
        }
        return nil
    }
}
