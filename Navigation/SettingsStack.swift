import SwiftUI

struct SettingsStack: View {
    let environment: AppEnvironment

    var body: some View {
        NavigationStack {
            SettingsView(environment: environment)
        }
    }
}
