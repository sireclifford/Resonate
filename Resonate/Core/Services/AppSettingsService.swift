import Foundation
import Combine

final class AppSettingsService: ObservableObject {

    private let defaults = UserDefaults.standard

    // MARK: - Reader

    @Published var fontSize: ReaderFontSize {
        didSet {
            defaults.set(fontSize.rawValue, forKey: Keys.fontSize)
        }
    }
    
    @Published var fontFamily: ReaderFontFamily {
        didSet {
            defaults.set(fontFamily.rawValue, forKey: Keys.fontFamily)
        }
    }
    
    @Published var lineSpacing: ReaderLineSpacing {
        didSet {
            defaults.set(lineSpacing.rawValue, forKey: Keys.lineSpacing)
        }
    }

    @Published var showVerseNumbers: Bool {
        didSet {
            defaults.set(showVerseNumbers, forKey: Keys.showVerseNumbers)
        }
    }
    
    @Published var chorusLabelStyle: ChorusLabelStyle {
        didSet {
            defaults.set(chorusLabelStyle.rawValue, forKey: Keys.chorusLabelStyle)
        }
    }

    // MARK: - Audio

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
        }
    }
    
    @Published var enableHaptics: Bool {
        didSet {
            defaults.set(enableHaptics, forKey: Keys.enableHaptics)
        }
    }

    // MARK: - Init

    init() {
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
        
        stopPlaybackOnExit = defaults.object(forKey: Keys.stopPlaybackOnExit) as? Bool ?? true
        
        enableHaptics = defaults.object(forKey: Keys.enableHaptics) as? Bool ?? true
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
    }
}
