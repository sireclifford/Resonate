import Foundation

enum NotificationAuthorizationStatus: Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    var isAllowedToSchedule: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}
