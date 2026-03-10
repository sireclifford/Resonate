import Foundation
import SwiftUI
import Combine

final class NavigationService: ObservableObject {
    @Published var requestedHymn: (id: Int, source: String)?

    func openHymn(id: Int, source: String) {
        requestedHymn = (id, source)
    }

    func consumeHymnRequest() {
        requestedHymn = nil
    }
}
