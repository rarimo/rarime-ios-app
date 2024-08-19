import Foundation

class RewardsViewModel: ObservableObject {
    @Published var selectedEvent: GetEventResponseData?

    @Published var pointsBalanceRaw: PointsBalanceRaw?
    @Published var events: [GetEventResponseData] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var totalParticipants: Int = 0

    init(event: GetEventResponseData? = nil) {
        selectedEvent = event
    }
}
