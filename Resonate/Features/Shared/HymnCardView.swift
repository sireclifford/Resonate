import SwiftUI

struct HymnCardView: View {

    let hymn: Hymn
    let isFavourite: Bool
    let onFavouriteToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)

                Button(action: onFavouriteToggle) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .foregroundColor(isFavourite ? .red : .secondary)
                        .padding(8)
                }
            }

            Text("Hymns \(hymn.id) • \(hymn.verses.count) Verses")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(hymn.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)

            Text(hymn.category.title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}


#Preview {
    HymnCardView(
        hymn: Hymn(
            id: 28,
            title: "To God Be the Glory",
            verses: Array(repeating: ["Line 1", "Line 2"], count: 6),
            chorus: nil,
            category: .praise,
            language: .english
        ),
        isFavourite: true,
        onFavouriteToggle: {}
    )
    .padding()
}
