import Foundation

struct PointsBalance: Equatable {
    var id: String
    var amount: Double
    var rank: Int
    var level: Int
    var activeCodes: [String]?
    var activatedCodes: [String]?
    var usedCodes: [String]?
}

let inviteFriendEvent = GetEventResponseData(
    id: "dasd",
    type: "dasd",
    attributes: GetEventResponseAttributes(
        status: "active",
        createdAt: Int(Date().timeIntervalSince1970),
        updatedAt: Int(Date().timeIntervalSince1970),
        meta: GetEventResponseMeta(
            metaStatic: GetEventResponseStatic(
                name: "invite_friends",
                reward: 5,
                title: "Invite users",
                description: "Full description text",
                shortDescription: "Invite friends in to app",
                frequency: "always",
                startsAt: nil,
                expiresAt: nil,
                actionURL: nil,
                logo: "https://pbs.twimg.com/profile_images/1639021161257263105/XmT0EBnK_400x400.jpg"
            )
        ),
        pointsAmount: nil
    )
)

let myBalance = PointsBalance(
    id: "42beAoalsOSLals3",
    amount: 12,
    rank: 16,
    level: 2,
    activeCodes: ["zgsScguZ", "jerUsmac"],
    activatedCodes: ["rCx18MZ4"],
    usedCodes: ["73k3bdYaFWM", "9csIL7dW65m"]
)

//  TODO: move to model
struct LevelReward {
    let title: String
    let description: String
    let icon: String
}

struct PointsLevel {
    let level: Int
    let description: String
    let minBalance: Double
    let maxBalance: Double
    let rewards: [LevelReward]
}

let pointsLevels: [PointsLevel] = [
    PointsLevel(
        level: 1,
        description: String(localized: "Reserve tokens to unlock new levels and rewards"),
        minBalance: 0,
        maxBalance: 10,
        rewards: [
            LevelReward(
                title: String(localized: "\(5) referrals"),
                description: String(localized: "Invite more people, earn more rewards"),
                icon: Icons.users
            ),
            LevelReward(
                title: String(localized: "Rewards campaigns"),
                description: String(localized: "Only level \(1) specials"),
                icon: Icons.airdrop
            )
        ]
    ),
    PointsLevel(
        level: 2,
        description: String(localized: "Reserve tokens to unlock new levels and rewards"),
        minBalance: 10,
        maxBalance: 30,
        rewards: [
            LevelReward(
                title: String(localized: "\(10) extra referrals"),
                description: String(localized: "Invite more people, earn more rewards"),
                icon: Icons.users
            ),
            LevelReward(
                title: String(localized: "Exclusive campaigns"),
                description: String(localized: "Only level \(2) specials"),
                icon: Icons.airdrop
            )
        ]
    ),
    PointsLevel(
        level: 3,
        description: String(localized: "Reserve tokens to unlock new levels and rewards"),
        minBalance: 30,
        maxBalance: 100,
        rewards: [
            LevelReward(
                title: String(localized: "\(20) extra referrals"),
                description: String(localized: "Invite more people, earn more rewards"),
                icon: Icons.users
            ),
            LevelReward(
                title: String(localized: "Exclusive campaigns"),
                description: String(localized: "Only level \(3) specials"),
                icon: Icons.airdrop
            )
        ]
    )
]
