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

    @Published var showVerseNumbers: Bool {
        didSet {
            defaults.set(showVerseNumbers, forKey: Keys.showVerseNumbers)
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

    // MARK: - Init

    init() {
        fontSize = ReaderFontSize(
            rawValue: defaults.string(forKey: Keys.fontSize) ?? "medium"
        ) ?? .medium

        showVerseNumbers = defaults.object(forKey: Keys.showVerseNumbers) as? Bool ?? true

        autoDownloadAudio = defaults.object(forKey: Keys.autoDownloadAudio) as? Bool ?? true

        allowCellularDownload = defaults.object(forKey: Keys.allowCellularDownload) as? Bool ?? false
    }

    private struct Keys {
        static let fontSize = "settings.fontSize"
        static let showVerseNumbers = "settings.showVerseNumbers"
        static let autoDownloadAudio = "settings.autoDownloadAudio"
        static let allowCellularDownload = "settings.allowCellularDownload"
    }
}
