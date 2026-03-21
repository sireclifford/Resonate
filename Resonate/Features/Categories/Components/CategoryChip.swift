import SwiftUI

struct CategoryChip: View {

    let title: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(PremiumTheme.scaledSystem(size: 14, weight: .semibold, design: .serif))

            Text("\(count) hymns")
                .font(PremiumTheme.captionFont())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
