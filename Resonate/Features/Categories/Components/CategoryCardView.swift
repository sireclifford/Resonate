import SwiftUI

struct CategoryCardView: View {

    let category: HymnCategory
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(category.title)
                .font(.josefin(size: 16, weight: .semibold))

            Text("\(count) Hymns")
                .font(.josefin(size: 13))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
