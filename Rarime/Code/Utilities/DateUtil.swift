import Foundation

enum DateParseError: Error {
    case invalidFormat
}

enum DurationPrecision {
    case seconds
    case minutes
}

struct DurationParts {
    let days: UInt
    let hours: UInt
    let minutes: UInt
    let seconds: UInt
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

    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter
    }()

    static let mrzDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.timeZone = .gmt
        return formatter
    }()

    static func parsePassportDate(_ value: String, _ isBirthDate: Bool = false) throws -> Date {
        guard let date = passportDateFormatter.date(from: value) else {
            throw DateParseError.invalidFormat
        }

        let currentDate = Date()
        if date > currentDate && isBirthDate {
            // substract 100 years from date
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: date)
            let newDate = calendar.date(byAdding: .year, value: -100, to: date)
            return newDate ?? date
        }

        return date
    }

    static func formatDurationParts(_ seconds: UInt) -> DurationParts {
        let SECONDS_IN_MINUTE: UInt = 60
        let SECONDS_IN_HOUR: UInt = 3600
        let SECONDS_IN_DAY: UInt = 86400

        let days = seconds / SECONDS_IN_DAY
        let hours = (seconds % SECONDS_IN_DAY) / SECONDS_IN_HOUR
        let minutes = (seconds % SECONDS_IN_HOUR) / SECONDS_IN_MINUTE
        let seconds = seconds % SECONDS_IN_MINUTE

        return DurationParts(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }

    static func formatDuration(_ seconds: UInt, precision: DurationPrecision = .seconds) -> String {
        let parts = formatDurationParts(seconds)

        if parts.days > 0 {
            return parts.days == 1
                ? String(localized: "1 day")
                : String(localized: "\(parts.days) days")
        }

        var result = ""
        if parts.hours > 0 {
            result += String(localized: "\(parts.hours)h") + " "
        }

        if parts.minutes > 0 {
            result += String(localized: "\(parts.minutes)m") + " "
        }

        if parts.seconds > 0 && precision == .seconds {
            result += String(localized: "\(parts.seconds)s")
        }

        return result
    }

    static func yearsBetween(from startDate: Date, to endDate: Date = Date()) -> Int {
        // Add 0.25 per year to account for leap years
        let SECONDS_IN_YEAR = Int(365.25 * 24 * 60 * 60)
        let components = Calendar.current.dateComponents([.second], from: startDate, to: endDate)

        let diffInSeconds = components.second ?? 0
        let diffInYears = Int(diffInSeconds / SECONDS_IN_YEAR)
        return diffInSeconds < 0 ? 100 - diffInYears : diffInYears
    }
}
