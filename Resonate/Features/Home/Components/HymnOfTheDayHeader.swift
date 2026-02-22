import SwiftUI

struct HymnOfTheDayHeader: View {

    let index: HymnIndex

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Hymn of the Day")
                .font(.josefin(size: 22, weight: .semibold))

            Text("Hymn \(index.id) • \(index.title)")
                .font(.josefin(size: 15))
                .foregroundColor(.secondary)

            Text("Open Now")
                .font(.josefin(size: 15, weight: .medium))
        }
    }
}
