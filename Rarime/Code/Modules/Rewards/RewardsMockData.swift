import Foundation

// TODO: use structs from points service
struct PointsEventMeta: Equatable {
    let name: String
    let title: String
    let description: String
    let shortDescription: String
    let reward: Double
    let expiresAt: Date?
    let actionURL: String?
    let logo: String
}

struct PointsEvent: Identifiable, Equatable {
    let id = UUID()
    let meta: PointsEventMeta
}

struct PointsBalance: Equatable {
    var id: String
    var amount: Double
    var rank: Int
    var level: Int
    var activeCodes: [String]?
    var activatedCodes: [String]?
    var usedCodes: [String]?
}

let limitedEvents: [PointsEvent] = [
    PointsEvent(
        meta: PointsEventMeta(
            name: "initial_setup",
            title: "Initial setup of identity credentials",
            description: "Full description text",
            shortDescription: "Short description text",
            reward: 5,
            expiresAt: Date(timeIntervalSinceNow: 200000),
            actionURL: "https://example.com",
            logo: Images.rewardsTest1
        )
    ),
    PointsEvent(
        meta: PointsEventMeta(
            name: "initial_setup",
            title: "Initial setup of identity credentials",
            description: "Full description text",
            shortDescription: "Short description text",
            reward: 5,
            expiresAt: Date(timeIntervalSinceNow: 200000),
            actionURL: "https://example.com",
            logo: Images.rewardsTest2
        )
    )
]

let activeEvents: [PointsEvent] = [
    PointsEvent(
        meta: PointsEventMeta(
            name: "invite_friends",
            title: "Invite 5 users",
            description: "Full description text",
            shortDescription: "Invite friends in to app",
            reward: 5,
            expiresAt: nil,
            actionURL: nil,
            logo: Icons.users
        )
    ),
    PointsEvent(
        meta: PointsEventMeta(
            name: "get_poh",
            title: "Getting a PoH credential",
            description: "Full description text",
            shortDescription: "Short description text",
            reward: 5,
            expiresAt: nil,
            actionURL: "https://example.com",
            logo: Icons.identificationCard
        )
    )
]

let leaderboardBalances: [PointsBalance] = [
    PointsBalance(id: "mhQeweiAJdiligRt", amount: 85, rank: 1, level: 3),
    PointsBalance(id: "12beAoalsOSLals1", amount: 75, rank: 2, level: 3),
    PointsBalance(id: "fkdbeweOJdilwq1b", amount: 65, rank: 3, level: 3),
    PointsBalance(id: "12beAoalsOSLals1", amount: 55, rank: 4, level: 3),
    PointsBalance(id: "12beAoalsOSLals2", amount: 48, rank: 5, level: 3),
    PointsBalance(id: "12beAoalsOSLals3", amount: 45, rank: 6, level: 3),
    PointsBalance(id: "12beAoalsOSLals4", amount: 35, rank: 7, level: 3),
    PointsBalance(id: "12beAoalsOSLals5", amount: 35, rank: 8, level: 3),
    PointsBalance(id: "12beAoalsOSLals6", amount: 33, rank: 9, level: 3),
    PointsBalance(id: "12beAoalsOSLals7", amount: 31, rank: 10, level: 3),
    PointsBalance(id: "mhQeweiAJdiligRw", amount: 25, rank: 11, level: 2),
    PointsBalance(id: "12beAoalsOSLalsw", amount: 18, rank: 12, level: 2),
    PointsBalance(id: "fkdbeweOJdilwq1w", amount: 15, rank: 13, level: 2),
    PointsBalance(id: "22beAoalsOSLals1", amount: 14, rank: 14, level: 2),
    PointsBalance(id: "32beAoalsOSLals2", amount: 13, rank: 15, level: 2),
    PointsBalance(id: "42beAoalsOSLals3", amount: 12, rank: 16, level: 2),
    PointsBalance(id: "52beAoalsOSLals4", amount: 6, rank: 17, level: 1),
    PointsBalance(id: "62beAoalsOSLals5", amount: 6, rank: 18, level: 1),
    PointsBalance(id: "72beAoalsOSLals6", amount: 5, rank: 19, level: 1),
    PointsBalance(id: "82beAoalsOSLals7", amount: 4, rank: 20, level: 1)
]

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
