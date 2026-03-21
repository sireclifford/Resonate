import SwiftUI

struct SettingsStack: View {
    let environment: AppEnvironment
    @ObservedObject private var audioService: AccompanimentPlaybackService

    init(environment: AppEnvironment) {
        self.environment = environment
        _audioService = ObservedObject(wrappedValue: environment.accompanimentPlaybackService)
    }

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            NavigationStack {
                SettingsView(environment: environment)
            }
        }
    }
}
