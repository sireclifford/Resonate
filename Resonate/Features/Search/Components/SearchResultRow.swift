import SwiftUI

struct SearchResultRow: View {

    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("\(result.hymn.id). \(result.hymn.title)")
                .font(.josefin(size: 15, weight: .medium))

            Text(result.matchedText)
                .font(.josefin(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }
}
