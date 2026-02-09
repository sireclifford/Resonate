import SwiftUI

@main
struct ResonateApp: App {
    @StateObject private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(environment)
        }
    }
}
