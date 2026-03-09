import SwiftUI

struct ToastOverlayModifier: ViewModifier {
    @ObservedObject var toastCenter: ToastCenter

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if let toast = toastCenter.currentToast {
                    ToastView(toast: toast)
                        .padding(.horizontal, 16)
                        .padding(edgeInsets)
                        .transition(transition)
                        .zIndex(999)
                        .onTapGesture {
                            toastCenter.hide()
                        }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .dismissToast)) { _ in
                    toastCenter.hide()
            }
    }

    private var alignment: Alignment {
        switch toastCenter.position {
        case .top: return .top
        case .bottom: return .bottom
        }
    }

    private var edgeInsets: EdgeInsets {
        switch toastCenter.position {
        case .top:
            return EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0)
        case .bottom:
            return EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0)
        }
    }

    private var transition: AnyTransition {
        switch toastCenter.position {
        case .top:
            return .move(edge: .top).combined(with: .opacity)
        case .bottom:
            return .move(edge: .bottom).combined(with: .opacity)
        }
    }
}

extension View {
    func toastOverlay(using toastCenter: ToastCenter) -> some View {
        modifier(ToastOverlayModifier(toastCenter: toastCenter))
    }
}

extension Notification.Name {
    static let dismissToast = Notification.Name("dismissToast")
}
