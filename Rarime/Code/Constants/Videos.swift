import Foundation

enum Videos {
    static let removeCase = Bundle.main.url(forResource: "RemoveCase", withExtension: "mp4")!
    static let scanMrz = Bundle.main.url(forResource: "ScanMrz", withExtension: "mp4")!
    static let readNfc = Bundle.main.url(forResource: "ReadNfc", withExtension: "mp4")!
    static let readNfcUsa = Bundle.main.url(forResource: "ReadNfcUsa", withExtension: "mp4")!
    static let scanMrzUsa = Bundle.main.url(forResource: "ScanMrzUsa", withExtension: "mp4")!
}
