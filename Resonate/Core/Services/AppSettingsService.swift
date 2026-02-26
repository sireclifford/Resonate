import Foundation
import SwiftUI
import Combine

final class AppSettingsService: ObservableObject {

    @AppStorage("selectedBibleID") var selectedBibleID: Int = 3034
    private let defaults = UserDefaults.standard
    private let analytics: AnalyticsService
    
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
                AnalyticsParameter.fontFamily.rawValue: fontFamily.rawValue
            ])
        }
    }
    
    @Published var lineSpacing: ReaderLineSpacing {
        didSet {
            defaults.set(lineSpacing.rawValue, forKey: Keys.lineSpacing)
            analytics.log(.lineSpacingChanged, parameters: [
                AnalyticsParameter.lineSpacing.rawValue: lineSpacing.rawValue
            ])
        }
    }

    @Published var showVerseNumbers: Bool {
        didSet {
            defaults.set(showVerseNumbers, forKey: Keys.showVerseNumbers)
            analytics.log(.verseNumbersToggled, parameters: [
                "enabled": showVerseNumbers
            ])
        }
    }
    
    @Published var chorusLabelStyle: ChorusLabelStyle {
        didSet {
            defaults.set(chorusLabelStyle.rawValue, forKey: Keys.chorusLabelStyle)
            analytics.log(.chorusLabelChanged, parameters: [
                AnalyticsParameter.chorusLabel.rawValue: chorusLabelStyle.rawValue
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
                "enabled": stopPlaybackOnExit
            ])
        }
    }
    
    @Published var enableHaptics: Bool {
        didSet {
            defaults.set(enableHaptics, forKey: Keys.enableHaptics)
            analytics.log(.hapticsToggled, parameters: [
                "enabled": enableHaptics
            ])
        }
    }
    
    @Published var theme: AppTheme {
        didSet {
            defaults.set(theme.rawValue, forKey: Keys.theme)
            analytics.log(.themeChanged, parameters: [
                AnalyticsParameter.theme.rawValue: theme.rawValue
            ])
        }
    }
    

    init(analytics: AnalyticsService) {
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
        
        static let dailyReminderTime = "dailyReminderTime"
        static let dailyReminderEnabled = "dailyReminderEnabled"
    }
}
