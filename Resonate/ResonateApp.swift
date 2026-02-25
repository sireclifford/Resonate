import SwiftUI
import YouVersionPlatform
import Firebase

@main
struct ResonateApp: App {
    @StateObject private var environment = AppEnvironment()
    
    init() {
        YouVersionPlatform.configure(appKey: "gSTExotiejEWpm6iAL9Js2g4ySwgQB9eDhQzxvwqO4uGReVv")
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootTabView(environment: environment)
                .environmentObject(environment)
        }
    }
}
