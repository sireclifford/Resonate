import SwiftUI

enum MiniPlayerLayout {
    static let fallbackTopInset: CGFloat = 84
}

private struct MiniPlayerInsetModifier: ViewModifier {
    let environment: AppEnvironment
    @ObservedObject private var audioService: AccompanimentPlaybackService

    init(environment: AppEnvironment) {
        self.environment = environment
        _audioService = ObservedObject(wrappedValue: environment.accompanimentPlaybackService)
    }

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .top, spacing: 0) {
            if audioService.currentHymnID != nil {
                MiniPlayerView(environment: environment)
                    .environmentObject(environment)
                    .padding(.top, 8)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.88), value: audioService.currentHymnID)
    }
}

extension View {
    func miniPlayerInset(using environment: AppEnvironment) -> some View {
        modifier(MiniPlayerInsetModifier(environment: environment))
    }
}
