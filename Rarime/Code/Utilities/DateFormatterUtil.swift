//
//  DateFormatter.swift
//  Rarime
//
//  Created by Maksym Shopynskyi on 02.04.2024.
//

import Foundation

class DateFormatterUtil {
    static let mdy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = .gmt
        return formatter
    }()
}
