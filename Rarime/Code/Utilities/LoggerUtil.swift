import Foundation
import os

class LoggerUtil {
    static let subsystem = Bundle.main.bundleIdentifier ?? "Undefined"
    static let passport = Logger(subsystem: subsystem, category: "Passport")
    static let qr = Logger(subsystem: subsystem, category: "QR Code")
}