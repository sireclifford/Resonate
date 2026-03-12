import SwiftUI

struct AppRootView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var showOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            RootTabView(environment: environment)
                .environmentObject(environment)

            if showOnboarding {
                OnboardingView(
                    analytics: environment.analyticsService,
                    onBeginWorship: {
                        // Mark first launch complete and dismiss onboarding
                        environment.settingsService.markFirstLaunchCompleted()
                        environment.analyticsService.onboardingCompleted()
                        showOnboarding = false

                        environment.settingsService.shouldAutoOpenHymnOfDay = true
                    },
                    onDismiss: {
                        // Mark first launch complete and dismiss onboarding
                        environment.settingsService.markFirstLaunchCompleted()
                        showOnboarding = false
                    }
                )
                .environmentObject(environment)
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                showOnboarding = !environment.settingsService.hasLaunchedBeforePublished
                if showOnboarding {
                    environment.analyticsService.onboardingShown()
                }
            }

            Task {
                await environment.onAppBecameActive()
            }
        }
        .onChange(of: environment.settingsService.hasLaunchedBeforePublished) { _, newValue in
            showOnboarding = !newValue
            if showOnboarding {
                environment.analyticsService.onboardingShown()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                let source = environment.pendingSessionSource ?? "direct"
                environment.sessionService.startSession(source: source)
                environment.pendingSessionSource = nil

                Task {
                    await environment.onAppBecameActive()
                }
            case .background:
                environment.sessionService.endSession()
            default:
                break
            }
        }
        .toastOverlay(using: environment.toastCenter)
    }
}

