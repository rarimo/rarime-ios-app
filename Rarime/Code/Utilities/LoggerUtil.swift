import OSLog
import Foundation

class LoggerUtil {
    static let subsystem = Bundle.main.bundleIdentifier ?? "Undefined"
    static let intro = Logger(subsystem: subsystem, category: "Intro")
    static let passport = Logger(subsystem: subsystem, category: "Passport")
    static let qr = Logger(subsystem: subsystem, category: "QR Code")
    static let common = Logger(subsystem: subsystem, category: "Common")
    
    static func export() throws -> [String] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(timeIntervalSinceLatestBoot: 1)
        let entries = try store
            .getEntries(at: position)
            .compactMap { $0 as? OSLogEntryLog }
            .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
            .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
        
        return entries
    }
}
