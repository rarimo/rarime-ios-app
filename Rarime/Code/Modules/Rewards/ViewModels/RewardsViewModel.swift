import Foundation

class RewardsViewModel: ObservableObject {
    @Published var selectedEvent: GetEventResponseData?
    
    @Published var pointsBalanceRaw: PointsBalanceRaw?
    @Published var events: [GetEventResponseData] = []

    init(event: GetEventResponseData? = nil) {
        selectedEvent = event
    }
}
