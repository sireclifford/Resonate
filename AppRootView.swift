import SwiftUI

struct AppRootView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var showOnboarding = false

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
            }

            rescheduleDailyReminderIfNeeded()
        }
        .onChange(of: environment.settingsService.hasLaunchedBeforePublished) { _, newValue in
            showOnboarding = !newValue
        }
        .onChange(of: environment.settingsService.dailyReminderEnabled) { _, _ in
            rescheduleDailyReminderIfNeeded()
        }
        .onChange(of: environment.settingsService.dailyReminderTime) { _, _ in
            rescheduleDailyReminderIfNeeded()
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
    }
}
