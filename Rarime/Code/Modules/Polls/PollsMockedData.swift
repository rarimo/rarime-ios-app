import Web3
import Foundation

let ACTIVE_POLLS: [Poll] = [
    Poll(
        id: 1,
        image: nil,
        title: String(localized: "Pre-elections polls"),
        description: String(localized: "Your vote counts, and you will be rewarded for every participation"),
        startsAt: Date(),
        duration: 10000,
        status: .started,
        questions: [
            .init(
                title: "What form of government do you consider to be the most suitable for the country?",
                variants: [
                    "Democracy",
                    "Dictatorship",
                    "Monarchy",
                    "Anarchy",
                    "People's Republic 1",
                    "People's Republic 2",
                    "People's Republic 3",
                    "Haven’t decided yet"
                ],
                isSkipable: false
            ),
            .init(
                title: "What form of government do you consider to be the most suitable for the country?",
                variants: [
                    "Democracy",
                    "Dictatorship",
                    "Haven’t decided yet"
                ],
                isSkipable: true
            )
        ],
        votingsAddresses: [],
        votingData: [],
        eventId: 0,
        proposalSMT: try! EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
        proposalResults: []
    )
]

let FINISHED_POLLS: [Poll] = [
    Poll(
        id: 2,
        image: nil,
        title: "Finished poll",
        description: "Your vote counts, and you will be rewarded for every participation",
        startsAt: Date().addingTimeInterval(-20 * 24 * 60 * 60), // 20 days ago
        duration: 10 * 24 * 60 * 60, // 10 days
        status: .ended,
        questions: [
            .init(
                title: "What form of government do you consider to be the most suitable for the country?",
                variants: [
                    "Democracy",
                    "Dictatorship",
                    "Haven’t decided yet"
                ],
                isSkipable: false
            ),
            .init(
                title: "What form of government do you consider to be the most suitable for the country?",
                variants: [
                    "Democracy",
                    "Dictatorship",
                    "Haven’t decided yet"
                ],
                isSkipable: true
            )
        ],
        votingsAddresses: [],
        votingData: [],
        eventId: 0,
        proposalSMT: try! EthereumAddress(hex: "0x0000000000000000000000000000000000000000", eip55: false),
        proposalResults: [
            [
                100,
                200,
                50
            ],
            [
                150,
                100,
                50
            ]
        ]
    )
]

