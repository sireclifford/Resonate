import SwiftUI

struct HomeCategoriesSection: View {

    let categories: [HymnCategory]
    let counts: [HymnCategory: Int]
    let onSeeAll: () -> Void
    let onSelect: (HymnCategory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Categories")
                    .font(.josefin(size: 18, weight: .semibold))

                Spacer()

                Button("See all", action: onSeeAll)
                    .font(.josefin(size: 14))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(categories.prefix(5)) { category in
                    CategoryRow(
                        title: category.title,
                        count: counts[category] ?? 0,
                        onTap: {
                            onSelect(category)
                        }
                    )
                }
            }
        }
    }
}

