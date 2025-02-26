import Web3
import Foundation

struct Poll: Identifiable {
    let id: UInt
    let title: String
    let description: String
    let startsAt: Date
    let duration: UInt
    let status: ProposalStatus
    let questions: [Question]
    let votingsAddresses: [EthereumAddress]
    let votingData: [Data]
    let eventId: BigUInt
    let proposalSMT: EthereumAddress
    let proposalResults: [[BigUInt]]

    var endAt: String {
        let endDate = self.startsAt.addingTimeInterval(Double(self.duration))

        if self.status == .ended {
            return String(localized: "Finished")
        }

        if self.status == .waiting {
            return String(localized: "Soon")
        }

        return DateUtil.formatDuration(UInt(endDate.timeIntervalSinceNow), precision: .minutes)
    }
}

struct Question {
    let title: String
    let variants: [String]
    let isSkipable: Bool
}
