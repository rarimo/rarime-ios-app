import Foundation

private let checkSumCoderDict = [
    "0": "0",
    "1": "1",
    "2": "2",
    "3": "3",
    "4": "4",
    "5": "5",
    "6": "6",
    "7": "7",
    "8": "8",
    "9": "9",
    "<": "0",
    " ": "0",
    "A": "10",
    "B": "11",
    "C": "12",
    "D": "13",
    "E": "14",
    "F": "15",
    "G": "16",
    "H": "17",
    "I": "18",
    "J": "19",
    "K": "20",
    "L": "21",
    "M": "22",
    "N": "23",
    "O": "24",
    "P": "25",
    "Q": "26",
    "R": "27",
    "S": "28",
    "T": "29",
    "U": "30",
    "V": "31",
    "W": "32",
    "X": "33",
    "Y": "34",
    "Z": "35"
]

class PassportUtils {
    static func getMRZKey(passportNumber: String, dateOfBirth: String, dateOfExpiry: String) -> String {
        let pptNr = pad(passportNumber, fieldLength: 9)
        let dob = pad(dateOfBirth, fieldLength: 6)
        let exp = pad(dateOfExpiry, fieldLength: 6)
        
        let passportNrChksum = calcCheckSum(pptNr)
        let dateOfBirthChksum = calcCheckSum(dob)
        let expiryDateChksum = calcCheckSum(exp)
        
        let mrzKey = "\(pptNr)\(passportNrChksum)\(dob)\(dateOfBirthChksum)\(exp)\(expiryDateChksum)"
        
        return mrzKey
    }
    
    private static func pad(_ value: String, fieldLength: Int) -> String {
        let paddedValue = (value + String(repeating: "<", count: fieldLength)).prefix(fieldLength)
        return String(paddedValue)
    }
    
    private static func calcCheckSum(_ checkString: String) -> Int {
        var sum = 0
        var m = 0
        let multipliers: [Int] = [7, 3, 1]
        for c in checkString {
            guard let lookup = checkSumCoderDict["\(c)"],
                  let number = Int(lookup) else { return 0 }
            let product = number * multipliers[m]
            sum += product
            m = (m + 1) % 3
        }
        
        return sum % 10
    }
    
    public static func normalizeNationality(_ rawNationality: String) -> String {
        // Some passports (e.g. Germany) have one-letter codes instead of three-letter ones
        return rawNationality.replacingOccurrences(of: "<", with: "")
    }
}
