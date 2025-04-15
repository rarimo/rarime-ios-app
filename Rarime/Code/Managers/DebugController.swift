#if DEVELOPMENT

import Foundation

class DebugController {
    static let shared = DebugController()

    var shouldForceRegistration = false

    var shouldForceLightRegistration = false
}

#endif
