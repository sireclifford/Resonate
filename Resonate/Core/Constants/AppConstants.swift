import Foundation

enum AppLinks {
    static let appStore = URL(string: "https://apps.apple.com/app/id6759313354")!

    static var shareURL: URL {
        return appStore
    }

    static var shareMessage: String {
        "Join me on Resonate: \(shareURL.absoluteString)"
    }
}
