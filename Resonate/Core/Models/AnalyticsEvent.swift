enum AnalyticsEvent: String {
    // Hymn
    
    case hymnOpened        = "hymn_opened"
    case hymnFavourited    = "hymn_favourited"
    case hymnUnfavourited  = "hymn_unfavourited"
    case hymnAudioPlayed   = "hymn_audio_played"
    case hymnAudioPaused   = "hymn_audio_paused"
    case hymnAudioCompleted = "hymn_audio_completed"
    
    // Search
    
    case searchPerformed   = "search_performed"
    case searchResultTapped = "search_result_tapped"
    case searchEmptyResult = "search_empty_result"
    
    // Navigation
    
    case tabSwitched       = "tab_switched"
    case categoryOpened    = "category_opened"
    
    // Mini Player
    
    case miniPlayerTapped  = "miniplayer_tapped"
    case miniPlayerToggled  = "miniplayer_toggle"
    
    // Settings
    
    case themeChanged      = "theme_changed"
    case fontFamilyChanged = "font_family_changed"
    case lineSpacingChanged = "line_spacing_changed"
    case chorusLabelChanged = "chorus_label_changed"
    case verseNumbersToggled = "verse_numbers_toggled"
    case hapticsToggled = "haptics_toggled"
    case stopPlaybackToggled = "stop_playback_toggled"
    
    //Onboarding
    case onboardingShown = "onboarding_shown"
    case onboardingCompleted = "onboarding_completed"
    case onboardingSkipped = "onboarding_skipped"
    
    //Notification
    case notificationPromptShown = "notification_prompt_shown"
    case notificationPromptAccepted = "notification_prompt_accepted"
    case notificationPromptDeclined = "notification_prompt_declined"
    case onboardingNotificationCTATapped = "onboarding_notification_cta_tapped"
    
    case storyOpened         = "story_opened"
    case storyUnavailable    = "story_unavailable"
    case storyClosed         = "story_closed"
    
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
}

enum AnalyticsParameter: String {
    case hymnID      = "hymn_id"
    case category    = "category"
    case theme       = "theme"
    case tab         = "tab"
    case searchQuery = "search_query"
    case resetCount = "reset_count"
    case chorusLabel = "chorus_label"
    case lineSpacing = "line_spacing"
    case fontFamily = "font_family"
    case enabled = "enabled"
    case resultCount = "result_count"
    case source = "source"
    case sessionID = "session_id"
    case durationSeconds = "duration_seconds"
}
