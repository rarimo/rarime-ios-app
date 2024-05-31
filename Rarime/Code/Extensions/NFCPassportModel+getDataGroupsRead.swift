import Foundation
import NFCPassportReader

extension NFCPassportModel {
    func getDataGroupsRead() throws -> Data {
        var data: [DataGroupIdOuter: DataGroupOuter] = [:]

        for (k, v) in self.dataGroupsRead {
            data[k.toOuter() ?? .Unknown] = v.toOuter()
        }

        return try JSONEncoder().encode(data)
    }
}

extension DataGroup {
    func toOuter() -> DataGroupOuter {
        DataGroupOuter(data: Data(self.data))
    }
}

struct DataGroupOuter: Codable {
    var data: Data
}

extension DataGroupId {
    func toOuter() -> DataGroupIdOuter? {
        return DataGroupIdOuter(rawValue: self.rawValue)
    }
}

public enum DataGroupIdOuter: Int, CaseIterable, Codable {
    case COM = 0x60
    case DG1 = 0x61
    case DG2 = 0x75
    case DG3 = 0x63
    case DG4 = 0x76
    case DG5 = 0x65
    case DG6 = 0x66
    case DG7 = 0x67
    case DG8 = 0x68
    case DG9 = 0x69
    case DG10 = 0x6A
    case DG11 = 0x6B
    case DG12 = 0x6C
    case DG13 = 0x6D
    case DG14 = 0x6E
    case DG15 = 0x6F
    case DG16 = 0x70
    case SOD = 0x77
    case Unknown = 0x00
}
