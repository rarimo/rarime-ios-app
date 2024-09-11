import Foundation

// "20925303098627062266630214635967906856225360340756326562498326001746719100911", // 0 - nullifier
// "52992115355956", // 1 - birthDate
// "55216908480563", // 2 - expirationDate
// "0", // 3 - name
// "0", // 4 - nameResidual
// "0", // 5 - nationality
// "5589842", // 6 - citizenship
// "0", // 7 - sex
// "0", // 8 - documentNumber

class ZkpPubSignals {
    static let names: [String] = [
        "Nullifier",
        "Birth date",
        "Expiration date",
        "Name",
        "Name residual",
        "Nationality",
        "Citizenship",
        "Sex",
        "Document number"
    ]
    
    var rawSignals: [String]
    
    init(_ rawSignals: [String]) {
        self.rawSignals = rawSignals
        
        if self.rawSignals.count > 9 {
            self.rawSignals = Array(self.rawSignals[0..<9])
        }
    }
    
    func getSignals() -> [ZkpPubSignal] {
        var signals: [ZkpPubSignal] = []
        
        for i in 0..<rawSignals.count {
            
            signals.append(ZkpPubSignal(name: ZkpPubSignals.names[i], value: rawSignals[i]))
        }
        
        return signals
    }
}

struct ZkpPubSignal {
    let name: String
    let value: String
}
