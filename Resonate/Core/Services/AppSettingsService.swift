import Foundation
import SwiftUI
import Combine

final class AppSettingsService: ObservableObject {

    @AppStorage("selectedBibleID") var selectedBibleID: Int = 3034
    private let defaults = UserDefaults.standard
    private let analytics: AnalyticsService
    
    @Published var hasLaunchedBeforePublished: Bool
    
    @Published var sabbathReminderEnabled: Bool {
        didSet {
            defaults.set(sabbathReminderEnabled, forKey: Keys.sabbathReminderEnabled)
        }
    }
    @Published var sabbathReminderTime: Date {
        didSet {
            defaults.set(sabbathReminderTime, forKey: Keys.sabbathReminderTime)
        }
    }
    
    @Published var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: Keys.dailyReminderEnabled)
        }
    }
    @Published var dailyReminderTime: Date {
        didSet {
                UserDefaults.standard.set(dailyReminderTime, forKey: Keys.dailyReminderTime)
            }
    }

    @Published var selectedVersionId: Int {
        didSet {
            defaults.set(selectedVersionId, forKey: Keys.selectedVersionId)
        }
    }

    @Published var fontSize: ReaderFontSize {
        didSet {
            defaults.set(fontSize.rawValue, forKey: Keys.fontSize)
        }
    }
    
    @Published var fontFamily: ReaderFontFamily {
        didSet {
            defaults.set(fontFamily.rawValue, forKey: Keys.fontFamily)
            analytics.log(.fontFamilyChanged, parameters: [
                .fontFamily: fontFamily.rawValue
            ])
        }
    }
    
    @Published var lineSpacing: ReaderLineSpacing {
        didSet {
            defaults.set(lineSpacing.rawValue, forKey: Keys.lineSpacing)
            analytics.log(.lineSpacingChanged, parameters: [
                .lineSpacing: lineSpacing.rawValue
            ])
        }
    }

    @Published var showVerseNumbers: Bool {
        didSet {
            defaults.set(showVerseNumbers, forKey: Keys.showVerseNumbers)
            analytics.log(.verseNumbersToggled, parameters: [
                .enabled: showVerseNumbers
            ])
        }
    }
    
    @Published var chorusLabelStyle: ChorusLabelStyle {
        didSet {
            defaults.set(chorusLabelStyle.rawValue, forKey: Keys.chorusLabelStyle)
            analytics.log(.chorusLabelChanged, parameters: [
                .chorusLabel: chorusLabelStyle.rawValue
            ])
        }
    }

    @Published var autoDownloadAudio: Bool {
        didSet {
            defaults.set(autoDownloadAudio, forKey: Keys.autoDownloadAudio)
        }
    }

    @Published var allowCellularDownload: Bool {
        didSet {
            defaults.set(allowCellularDownload, forKey: Keys.allowCellularDownload)
        }
    }
    
    @Published var stopPlaybackOnExit: Bool {
        didSet {
            defaults.set(stopPlaybackOnExit, forKey: Keys.stopPlaybackOnExit)
            analytics.log(.stopPlaybackToggled, parameters: [
                .enabled: stopPlaybackOnExit
            ])
        }
    }
    
    @Published var enableHaptics: Bool {
        didSet {
            defaults.set(enableHaptics, forKey: Keys.enableHaptics)
            analytics.log(.hapticsToggled, parameters: [
                .enabled: enableHaptics
            ])
        }
    }
    
    @Published var theme: AppTheme {
        didSet {
            defaults.set(theme.rawValue, forKey: Keys.theme)
            analytics.log(.themeChanged, parameters: [
                .theme: theme.rawValue
            ])
        }
    }
    
    func markFirstLaunchCompleted() {
        defaults.set(true, forKey: Keys.hasLaunchedBefore)
        hasLaunchedBeforePublished = true
    }
    
    var shouldAutoOpenHymnOfDay: Bool {
        get { defaults.bool(forKey: Keys.shouldAutoOpenHymnOfDay) }
        set { defaults.set(newValue, forKey: Keys.shouldAutoOpenHymnOfDay) }
    }
    
    var skipTodayDailyReminder: Bool {
        get {
            let isSkipping = defaults.bool(forKey: Keys.skipTodayDailyReminder)
            guard isSkipping else { return false }

            // Auto-clear once the day changes
            let ts = defaults.double(forKey: Keys.skipTodayDailyReminderSetDate)
            if ts <= 0 { return true }

            let setDate = Date(timeIntervalSince1970: ts)
            if Calendar.current.isDateInToday(setDate) {
                return true
            } else {
                defaults.set(false, forKey: Keys.skipTodayDailyReminder)
                defaults.set(0.0, forKey: Keys.skipTodayDailyReminderSetDate)
                return false
            }
        }
        set {
            defaults.set(newValue, forKey: Keys.skipTodayDailyReminder)
            if newValue {
                defaults.set(Date().timeIntervalSince1970, forKey: Keys.skipTodayDailyReminderSetDate)
            } else {
                defaults.set(0.0, forKey: Keys.skipTodayDailyReminderSetDate)
            }
        }
    }
    
    var meaningfulSessionCount: Int {
        get { defaults.integer(forKey: Keys.meaningfulSessionCount) }
        set { defaults.set(newValue, forKey: Keys.meaningfulSessionCount) }
    }

    init(analytics: AnalyticsService) {
        self.hasLaunchedBeforePublished = defaults.bool(forKey: Keys.hasLaunchedBefore)
        self.analytics = analytics
        selectedVersionId = defaults.object(forKey: Keys.selectedVersionId) as? Int ?? 3034
        
        fontSize = ReaderFontSize(
            rawValue: defaults.string(forKey: Keys.fontSize) ?? "medium"
        ) ?? .medium
        
        fontFamily = ReaderFontFamily(
            rawValue: defaults.string(forKey: Keys.fontFamily) ?? "system") ?? .system
        
        lineSpacing = ReaderLineSpacing(
            rawValue: defaults.string(forKey: Keys.lineSpacing) ?? "comfortable"
        ) ?? .comfortable
        
        chorusLabelStyle = ChorusLabelStyle(
            rawValue: defaults.string(forKey: Keys.chorusLabelStyle) ?? "chorus"
        ) ?? .chorus
        
        showVerseNumbers = defaults.object(forKey: Keys.showVerseNumbers) as? Bool ?? true
        
        autoDownloadAudio = defaults.object(forKey: Keys.autoDownloadAudio) as? Bool ?? true
        
        allowCellularDownload = defaults.object(forKey: Keys.allowCellularDownload) as? Bool ?? false
        
        stopPlaybackOnExit = defaults.object(forKey: Keys.stopPlaybackOnExit) as? Bool ?? false
        
        enableHaptics = defaults.object(forKey: Keys.enableHaptics) as? Bool ?? true
        
        theme = AppTheme(
            rawValue: defaults.string(forKey: Keys.theme) ?? "system"
        ) ?? .system
        
        self.sabbathReminderEnabled = defaults.object(forKey: Keys.sabbathReminderEnabled) as? Bool ?? false

        self.sabbathReminderTime = defaults.object(forKey: Keys.sabbathReminderTime) as? Date ?? {
            var components = DateComponents()
            components.hour = 18
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }()

        self.dailyReminderEnabled = defaults.object(forKey: Keys.dailyReminderEnabled) as? Bool ?? false

        self.dailyReminderTime = defaults.object(forKey: Keys.dailyReminderTime) as? Date ?? {
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            return Calendar.current.date(from: components) ?? Date()
        }()
    }

    private struct Keys {
        static let fontSize = "settings.fontSize"
        static let fontFamily = "settings.fontFamily"
        static let lineSpacing = "settings.lineSpacing"
        static let chorusLabelStyle = "settings.chorusLabelStyle"
        static let showVerseNumbers = "settings.showVerseNumbers"
        static let autoDownloadAudio = "settings.autoDownloadAudio"
        static let allowCellularDownload = "settings.allowCellularDownload"
        static let stopPlaybackOnExit = "settings.stopPlaybackOnExit"
        static let enableHaptics = "settings.enableHaptics"
        static let theme = "settings.theme"
        static let selectedVersionId = "settings.selectedVersionId"
        
        static let sabbathReminderTime = "sabbathReminderTime"
        static let sabbathReminderEnabled = "sabbathReminderEnabled"
        static let dailyReminderTime = "dailyReminderTime"
        static let dailyReminderEnabled = "dailyReminderEnabled"
        
        static let hasLaunchedBefore = "app.hasLaunchedBefore"
        static let shouldAutoOpenHymnOfDay = "app.shouldAutoOpenHymnOfDay"
        static let skipTodayDailyReminder = "app.skipTodayDailyReminder"
        static let skipTodayDailyReminderSetDate = "app.skipTodayDailyReminderSetDate"
        static let meaningfulSessionCount = "app.meaningfulSessionCount"
        
    }
}
