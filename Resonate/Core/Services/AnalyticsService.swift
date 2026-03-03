import FirebaseAnalytics

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    private init() {}
    
    // Core Logger
    
    func log(_ event: AnalyticsEvent, parameters: [AnalyticsParameter: Any]? = nil) {
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
            .resetCount: resultCount
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
}
