import SwiftUI

struct CategoryRow: View {

    let title: String
    let count: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))

                Text("\(count) hymns")
                    .font(PremiumTheme.captionFont())
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(PremiumTheme.scaledSystem(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
