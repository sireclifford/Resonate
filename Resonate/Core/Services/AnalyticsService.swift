import FirebaseAnalytics

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    private init() {}
    
    // Core Logger
    
    func log(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
    
    // Hymn Engagement
    
    func hymnOpened(id: Int, category: String) {
        log(.hymnOpened, parameters: [
            AnalyticsParameter.hymnID.rawValue: id,
            AnalyticsParameter.category.rawValue: category
        ])
    }
    
    func hymnFavourited(id: Int) {
        log(.hymnFavourited, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    func hymnUnfavourited(id: Int) {
        log(.hymnUnfavourited, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    func hymnAudioPlayed(id: Int) {
        log(.hymnAudioPlayed, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    func hymnAudioPaused(id: Int) {
        log(.hymnAudioPaused, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    func hymnAudioCompleted(id: Int) {
        log(.hymnAudioCompleted, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    // Search
    
    func searchPerformed(resultCount: Int) {
        log(.searchPerformed, parameters: [
            AnalyticsParameter.resetCount.rawValue: resultCount
        ])
    }
    
    func searchResultTapped(id: Int) {
        log(.searchResultTapped, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    func searchEmptyResult() {
        log(.searchEmptyResult)
    }
    
    // Navigation
    
    func tabSwitched(to tab: String) {
        log(.tabSwitched, parameters: [
            AnalyticsParameter.tab.rawValue: tab
        ])
    }
    
    func categoryOpened(_ category: String) {
        log(.categoryOpened, parameters: [
            AnalyticsParameter.category.rawValue: category
        ])
    }
    
    // Mini Player
    
    func miniPlayerTapped(id: Int) {
        log(.miniPlayerTapped, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    func miniPlayerToggled(id: Int) {
        log(.miniPlayerToggled, parameters: [
            AnalyticsParameter.hymnID.rawValue: id
        ])
    }
    
    // Settings
    
    func themeChanged(to theme: String) {
        log(.themeChanged, parameters: [
            AnalyticsParameter.theme.rawValue: theme
        ])
    }
    
    func fontChanged(to font: String) {
        log(.fontFamilyChanged, parameters: [
            AnalyticsParameter.fontFamily.rawValue: font
        ])
    }
    
    func lineSpacingChanged(to spacing: String) {
        log(.lineSpacingChanged, parameters: [
            AnalyticsParameter.lineSpacing.rawValue: spacing
        ])
    }
    
    func chorusStyleChanged(to style: String) {
        log(.chorusLabelChanged, parameters: [
            AnalyticsParameter.chorusLabel.rawValue: style
        ])
    }
    
    func verseNumbersToggled(isEnabled: Bool) {
        log(.verseNumbersToggled, parameters: [
            "enabled": isEnabled
        ])
    }
}
