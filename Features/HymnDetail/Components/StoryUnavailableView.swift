import SwiftUI

struct StoryUnavailableView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("Story Not Available")
                .font(.headline)

            Text("We are still adding historical and musical details for this hymn.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
