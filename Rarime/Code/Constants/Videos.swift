import Foundation

enum Videos {
    static let removeCase = Bundle.main.url(forResource: "RemoveCase", withExtension: "mp4")!
    static let scanMrz = Bundle.main.url(forResource: "ScanMrzPassport", withExtension: "mp4")!
    static let readNfc = Bundle.main.url(forResource: "ReadNfcPassport", withExtension: "mp4")!
}
