import Foundation

class RewardsViewModel: ObservableObject {
    @Published var selectedEvent: PointsEvent?
    
    @Published var pointsBalanceRaw: PointsBalanceRaw?

    init(event: PointsEvent? = nil) {
        selectedEvent = event
    }
}
