import SwiftUI

struct HymnOfTheDayHeader: View {

    let hymn: Hymn
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Hymns of the Day")
                .font(.josefin(size: 22, weight: .semibold))

            Text("Hymns \(hymn.id) • \(hymn.title)")
                .font(.josefin(size: 15))
                .foregroundColor(.secondary)

            Button("Open Now", action: onOpen)
                .font(.josefin(size: 15, weight: .medium))
        }
    }
}
