#if DEVELOPMENT

import Foundation

class DebugManager {
    static let shared = DebugManager()

    var shouldForceRegistration = false

    var shouldForceLightRegistration = false
}

#endif
