import Combine
import Foundation
import SwiftUI

@MainActor
final class ToastCenter: ObservableObject {
    @Published private(set) var currentToast: ToastMessage?
    @Published private(set) var position: ToastPosition = .bottom

    private var dismissTask: Task<Void, Never>?

    func show(_ toast: ToastMessage, position: ToastPosition = .bottom) {
        dismissTask?.cancel()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            self.position = position
            self.currentToast = toast
        }

        dismissTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))

            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                self.currentToast = nil
            }
        }
    }

    func hide() {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            currentToast = nil
        }
    }
}
