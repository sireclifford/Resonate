import FirebaseAnalytics

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    private init() {}
    
    /// Called when a logged event should count as meaningful user interaction (used for session tracking).
    var onMeaningfulInteraction: (() -> Void)?
    
    // Define which events count as meaningful interactions for session tracking.
    // Adjust this list as your definition of "meaningful" evolves.
    private let meaningfulEvents: Set<AnalyticsEvent> = [
        // Existing meaningful interactions
        .hymnFavourited,
        .hymnAudioPaused,
        .hymnAudioCompleted,
        .searchResultTapped,
        // Onboarding interactions you want to count as meaningful
        .onboardingCompleted,
        .onboardingNotificationCTATapped
    ]
    
    // Core Logger
    
    func log(_ event: AnalyticsEvent, parameters: [AnalyticsParameter: Any]? = nil) {
        // Mark meaningful engagement for session tracking.
        if meaningfulEvents.contains(event) {
            onMeaningfulInteraction?()
        }

        var converted: [String: Any] = [:]
        
        parameters?.forEach { key, value in
            converted[key.rawValue] = value
        }
        
        Analytics.logEvent(event.rawValue, parameters: converted)
    }
    
    // Hymn Engagement
    
    func hymnOpened(id: Int, category: String) {
        log(.hymnOpened, parameters: [
            .hymnID: id,
            .category: category
        ])
    }
    
    func hymnOpened(id: Int, category: String, source: String) {
        log(.hymnOpened, parameters: [
            .hymnID: id,
            .category: category,
            .source: source
        ])
    }
    
    func hymnFavourited(id: Int) {
        log(.hymnFavourited, parameters: [
            .hymnID: id
        ])
    }
    
    func hymnUnfavourited(id: Int) {
        log(.hymnUnfavourited, parameters: [
            .hymnID: id
        ])
    }
    
    func hymnAudioPlayed(id: Int) {
        log(.hymnAudioPlayed, parameters: [
            .hymnID: id
        ])
    }
    
    func hymnAudioPaused(id: Int) {
        log(.hymnAudioPaused, parameters: [
            .hymnID: id
        ])
    }
    
    func hymnAudioCompleted(id: Int) {
        log(.hymnAudioCompleted, parameters: [
            .hymnID: id
        ])
    }
    
    // Search
    
    func searchPerformed(resultCount: Int) {
        log(.searchPerformed, parameters: [
            .resultCount: resultCount
        ])
    }
    
    func searchResultTapped(id: Int) {
        log(.searchResultTapped, parameters: [
            .hymnID: id
        ])
    }
    
    func searchEmptyResult() {
        log(.searchEmptyResult)
    }
    
    // Navigation
    
    func tabSwitched(to tab: String) {
        log(.tabSwitched, parameters: [
            .tab: tab
        ])
    }
    
    func categoryOpened(_ category: String) {
        log(.categoryOpened, parameters: [
            .category: category
        ])
    }
    
    // Mini Player
    
    func miniPlayerTapped(id: Int) {
        log(.miniPlayerTapped, parameters: [
            .hymnID: id
        ])
    }
    
    func miniPlayerToggled(id: Int) {
        log(.miniPlayerToggled, parameters: [
            .hymnID: id
        ])
    }
    
    // Settings
    
    func themeChanged(to theme: String) {
        log(.themeChanged, parameters: [
            .theme: theme
        ])
    }
    
    func fontChanged(to font: String) {
        log(.fontFamilyChanged, parameters: [
            .fontFamily: font
        ])
    }
    
    func lineSpacingChanged(to spacing: String) {
        log(.lineSpacingChanged, parameters: [
            .lineSpacing: spacing
        ])
    }
    
    func chorusStyleChanged(to style: String) {
        log(.chorusLabelChanged, parameters: [
            .chorusLabel: style
        ])
    }
    
    func verseNumbersToggled(isEnabled: Bool) {
        log(.verseNumbersToggled, parameters: [
            .enabled: isEnabled
        ])
    }
    
    // MARK: - Onboarding

    func onboardingShown() {
        log(.onboardingShown, parameters: [.source: "onboarding"])
    }

    func onboardingCompleted() {
        log(.onboardingCompleted, parameters: [.source: "onboarding"])
    }

    func onboardingSkipped() {
        log(.onboardingSkipped, parameters: [.source: "onboarding"])
    }

    func onboardingNotificationCTATapped() {
        log(.onboardingNotificationCTATapped, parameters: [.source: "onboarding"])
    }

    // MARK: - Notification Prompt

    func notificationPromptShown() {
        log(.notificationPromptShown)
    }

    func notificationPromptAccepted() {
        log(.notificationPromptAccepted)
    }

    func notificationPromptDeclined() {
        log(.notificationPromptDeclined)
    }

    // MARK: - Session (optional wrappers)

    func sessionStarted(source: String = "direct", sessionID: String) {
        log(.sessionStarted, parameters: [
            .source: source,
            .sessionID: sessionID
        ])
    }

    func sessionCompleted(sessionID: String, durationSeconds: Int) {
        log(.sessionCompleted, parameters: [
            .sessionID: sessionID,
            .durationSeconds: durationSeconds
        ])
    }
    
    // MARK: - Reminders (minimal funnel)

    func reminderScheduled(timeBucket: String) {
        log(.categoryOpened, parameters: [ // placeholder event name; replace with a dedicated event when added
            .category: "reminder_scheduled_\(timeBucket)"
        ])
    }

    func reminderNotificationTapped(hymnID: Int) {
        log(.searchResultTapped, parameters: [ // placeholder event name; replace with a dedicated event when added
            .hymnID: hymnID
        ])
    }

    func reminderHymnOpened(hymnID: Int) {
        log(.hymnOpened, parameters: [
            .hymnID: hymnID,
            .category: "reminder"
        ])
    }

    // MARK: - Story

    func storyOpened(hymnID: Int) {
        log(.storyOpened, parameters: [
            .hymnID: hymnID
        ])
    }

    func storyUnavailable(hymnID: Int) {
        log(.storyUnavailable, parameters: [
            .hymnID: hymnID
        ])
    }

    func storyClosed(hymnID: Int, durationSeconds: Int) {
        log(.storyClosed, parameters: [
            .hymnID: hymnID,
            .durationSeconds: durationSeconds
        ])
    }
}
