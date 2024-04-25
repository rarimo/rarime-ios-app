import Foundation
import os

class LoggerUtil {
    static let subsystem = Bundle.main.bundleIdentifier ?? "Undefined"
    static let general = Logger(subsystem: subsystem, category: "General")
    static let intro = Logger(subsystem: subsystem, category: "Intro")
    static let passport = Logger(subsystem: subsystem, category: "Passport")
    static let qr = Logger(subsystem: subsystem, category: "QR Code")
}
