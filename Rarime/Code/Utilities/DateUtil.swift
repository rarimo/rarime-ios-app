//
//  DateParser.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 03.04.2024.
//

import Foundation

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

    static func parsePassportDate(_ value: String) -> Date {
        guard let date = passportDateFormatter.date(from: value) else {
            return Date()
        }

        return date
    }
}
