import SwiftUI

struct RecentlyViewedPlaceholder: View {

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 28))
                .foregroundColor(.secondary)

            Text("No recently viewed hymns")
                .font(.subheadline)
                .foregroundColor(.primary)

            Text("Hymns you open will appear here.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
