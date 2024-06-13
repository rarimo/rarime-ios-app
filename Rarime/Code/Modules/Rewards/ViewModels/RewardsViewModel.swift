import Foundation

class RewardsViewModel: ObservableObject {
    @Published var selectedEvent: PointsEvent?

    init(event: PointsEvent? = nil) {
        selectedEvent = event
    }
}
