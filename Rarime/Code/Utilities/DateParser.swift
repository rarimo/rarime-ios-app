//
//  DateParser.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 03.04.2024.
//

import Foundation

class DateParser {
    private static let passportDateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        formatter.timeZone = .gmt
        return formatter
    }()

    static func parsePassportDate(_ value: String) -> Date {
        guard let date = passportDateParser.date(from: value) else {
            return Date()
        }

        return date
    }
}
