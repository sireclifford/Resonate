import UIKit

enum Haptics {
    private static let settingsKey = "settings.enableHaptics"

    static func light() {
        guard isEnabled else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func medium() {
        guard isEnabled else { return }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private static var isEnabled: Bool {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: settingsKey) as? Bool ?? true
    }
}
