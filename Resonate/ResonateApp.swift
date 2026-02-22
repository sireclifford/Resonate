import SwiftUI
import YouVersionPlatform

@main
struct ResonateApp: App {
    @StateObject private var environment = AppEnvironment()
    
    init() {
        YouVersionPlatform.configure(appKey: "gSTExotiejEWpm6iAL9Js2g4ySwgQB9eDhQzxvwqO4uGReVv")
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView(environment: environment)
                .environmentObject(environment)
        }
    }
}
