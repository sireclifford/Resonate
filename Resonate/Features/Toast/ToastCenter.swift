import Foundation
import SwiftUI
import Combine

@MainActor
final class ToastCenter: ObservableObject {
    @Published private(set) var currentToast: ToastMessage?
    @Published private(set) var position: ToastPosition = .bottom

    private var queue: [(ToastMessage, ToastPosition)] = []
    private var dismissTask: Task<Void, Never>?
    private var isPresenting = false

    func show(_ toast: ToastMessage, position: ToastPosition = .bottom) {
        queue.append((toast, position))
        presentNextIfNeeded()
    }

    func hide() {
        dismissTask?.cancel()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            currentToast = nil
        }

        isPresenting = false

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 180_000_000)
            presentNextIfNeeded()
        }
    }

    private func presentNextIfNeeded() {
        guard !isPresenting else { return }
        guard !queue.isEmpty else { return }

        let (toast, toastPosition) = queue.removeFirst()
        isPresenting = true

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            self.position = toastPosition
            self.currentToast = toast
        }

        Haptics.light()

        dismissTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                self.currentToast = nil
            }

            self.isPresenting = false

            try? await Task.sleep(nanoseconds: 180_000_000)
            self.presentNextIfNeeded()
        }
    }
    
    func replace(_ toast: ToastMessage, position: ToastPosition = .bottom) {
        dismissTask?.cancel()
        queue.removeAll()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
            self.position = position
            self.currentToast = toast
        }

        isPresenting = true

        dismissTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                self.currentToast = nil
            }

            self.isPresenting = false
        }
    }
}
