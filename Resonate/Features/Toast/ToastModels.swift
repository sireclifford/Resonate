import Foundation

enum ToastPosition {
    case top
    case bottom
}

enum ToastStyle {
    case success
    case error
    case info
}

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let style: ToastStyle
    let duration: TimeInterval
    
    init(
        title: String,
        subtitle: String? = nil,
        style: ToastStyle,
        duration: TimeInterval = 2.5
    ){
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.duration = duration
    }
}

extension ToastMessage {
    static func success(_ title: String, subtitle: String? = nil, duration: TimeInterval = 2.5) -> ToastMessage {
        ToastMessage(title: title, subtitle: subtitle, style: .success, duration: duration)
    }
    
    static func error(_ title: String, subtitle: String? = nil, duration: TimeInterval = 3.0) -> ToastMessage {
        ToastMessage(title: title, subtitle: subtitle, style: .error, duration: duration)
    }
    
    static func info(_ title: String, subtitle: String? = nil, duration: TimeInterval = 2.5) -> ToastMessage {
        ToastMessage(title: title, subtitle: subtitle, style: .info, duration: duration)
    }
}
