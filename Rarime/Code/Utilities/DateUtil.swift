import Foundation

enum DateParseError: Error {
    case invalidFormat
}

class DateUtil {
    static let passportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        formatter.timeZone = .gmt
        return formatter
    }()

    static let mdyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = .gmt
        return formatter
    }()

    static let richDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.timeZone = .gmt
        return formatter
    }()

    static let mrzDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.timeZone = .gmt
        return formatter
    }()

    static func parsePassportDate(_ value: String) throws -> Date {
        guard let date = passportDateFormatter.date(from: value) else {
            throw DateParseError.invalidFormat
        }

        return date
    }
}
