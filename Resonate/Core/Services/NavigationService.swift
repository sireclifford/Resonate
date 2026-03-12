import Foundation
import SwiftUI
import Combine

struct HymnNavigationRequest: Equatable {
    let id: Int
    let source: String
}

final class NavigationService: ObservableObject {
    @Published var requestedHymn: HymnNavigationRequest?

    func openHymn(id: Int, source: String) {
        requestedHymn = HymnNavigationRequest(id: id, source: source)
    }

    func openHymnFromMiniPlayer(id: Int) {
        openHymn(id: id, source: "miniplayer")
    }

    func openHymnFromNotification(id: Int) {
        openHymn(id: id, source: "notification")
    }

    func consumeHymnRequest() {
        requestedHymn = nil
    }
}
