import SwiftUI

struct EditorsPicksView: View {

    let environment: AppEnvironment

    var hymns: [HymnIndex] {
        environment.hymnService.index.filter {
            [1,21,99,152,245].contains($0.id)
        }
    }

    var body: some View {
        HymnListView(
            title: "Editor's Picks",
            hymns: hymns,
            environment: environment
        )
    }
}
