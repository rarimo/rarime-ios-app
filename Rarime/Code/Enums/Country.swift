import Foundation

enum Country {
    case usa, ukraine, georgia, germany, unitedKingdom, russia
    case unknown
}

extension Country {
    static func fromISOCode(_ code: String) -> Country {
        switch code {
        case "USA": .usa
        case "UKR": .ukraine
        case "GEO": .georgia
        case "DEU": .germany
        case "GBR": .unitedKingdom
        case "RUS": .russia
        default: .unknown
        }
    }
}

extension Country {
    var flag: String {
        switch self {
        case .usa: "🇺🇸"
        case .ukraine: "🇺🇦"
        case .georgia: "🇬🇪"
        case .germany: "🇩🇪"
        case .unitedKingdom: "🇬🇧"
        case .russia: "🇷🇺"
        case .unknown: "🏳️"
        }
    }
}

extension Country {
    var name: String {
        switch self {
        case .usa: String(localized: "United States")
        case .ukraine: String(localized: "Ukraine")
        case .georgia: String(localized: "Georgia")
        case .germany: String(localized: "Germany")
        case .unitedKingdom: String(localized: "United Kingdom")
        case .russia: String(localized: "Russia")
        case .unknown: String(localized: "Unknown Country")
        }
    }
}
