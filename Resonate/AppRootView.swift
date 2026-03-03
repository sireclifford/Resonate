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
                        environment.analyticsService.onboardingCompleted()
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

            rescheduleDailyReminderIfNeeded()
        }
        .onChange(of: environment.settingsService.hasLaunchedBeforePublished) { _, newValue in
            showOnboarding = !newValue
            if showOnboarding {
                environment.analyticsService.onboardingShown()
            }
        }
        .onChange(of: environment.settingsService.dailyReminderEnabled) { _, _ in
            rescheduleDailyReminderIfNeeded()
        }
        .onChange(of: environment.settingsService.dailyReminderTime) { _, _ in
            rescheduleDailyReminderIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                let source = environment.pendingSessionSource ?? "direct"
                environment.sessionService.startSession(source: source)
                environment.pendingSessionSource = nil
            case .background:
                environment.sessionService.endSession()
            default:
                break
            }
        }
    }

    private func rescheduleDailyReminderIfNeeded() {
        let startFromTomorrow = environment.settingsService.skipTodayDailyReminder
        // Always cancel first to avoid duplicates.
        environment.notificationService.cancelReminder()

        guard environment.settingsService.dailyReminderEnabled,
              let hymn = environment.hymnService.hymnOfTheDay() else {
            return
        }

        environment.notificationService.scheduleSmartDailyReminder(
            reminderTime: environment.settingsService.dailyReminderTime,
            hymn: hymn,
            engagementService: environment.hymnOfTheDayEngagementService,
            startFromTomorrow: startFromTomorrow
        )
        
        let hour = Calendar.current.component(.hour, from: environment.settingsService.dailyReminderTime)
        let bucket: String
        switch hour {
        case 5..<12: bucket = "morning"
        case 12..<18: bucket = "afternoon"
        case 18..<23: bucket = "evening"
        default: bucket = "night"
        }
        environment.analyticsService.reminderScheduled(timeBucket: bucket)
    }
}
