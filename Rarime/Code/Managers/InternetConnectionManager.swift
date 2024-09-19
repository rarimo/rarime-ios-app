import SwiftUI
import Network

class InternetConnectionManager: ObservableObject {
    static let shared = InternetConnectionManager()
    
    @Published var isInternetPresent: Bool = true
    
    private let monitor = NWPathMonitor()
    
    init() {
        monitor.pathUpdateHandler = { path in
            var isInternetPresent = true
            
            switch path.status {
            case .satisfied:
                isInternetPresent = true
            case .unsatisfied:
                isInternetPresent = false
            case .requiresConnection:
                isInternetPresent = false
            @unknown default:
                isInternetPresent = false
            }
            
            DispatchQueue.main.async {
                self.isInternetPresent = isInternetPresent
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
