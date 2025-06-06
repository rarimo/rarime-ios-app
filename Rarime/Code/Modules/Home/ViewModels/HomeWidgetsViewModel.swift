import Alamofire
import Foundation

class HomeWidgetsViewModel: ObservableObject {
    @Published private(set) var widgets: [HomeWidget]

    init() {
        let decodedWidgets = try? JSONDecoder().decode([String].self, from: AppUserDefaults.shared.homeWidgets)
        widgets = decodedWidgets?.compactMap { HomeWidget(rawValue: $0) } ?? DEFAULT_HOME_WIDGETS
    }

    func addWidget(_ widget: HomeWidget) {
        if !widgets.contains(widget) {
            widgets.append(widget)
            saveWidgets()
        }
    }

    func removeWidget(_ widget: HomeWidget) {
        if let index = widgets.firstIndex(of: widget) {
            widgets.remove(at: index)
            saveWidgets()
        }
    }

    func saveWidgets() {
        AppUserDefaults.shared.homeWidgets = (try? JSONEncoder().encode(widgets.map { $0.rawValue })) ?? Data()
    }

    func reset() {
        widgets = DEFAULT_HOME_WIDGETS
        saveWidgets()
    }
}
