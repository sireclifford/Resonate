import SwiftUI

struct HymnOfTheDayHeader: View {

    let hymn: Hymn
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Hymns of the Day")
                .font(.headline)

            Text("Hymns \(hymn.id) • \(hymn.title)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: onOpen) {
                Text("Open Now")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}
