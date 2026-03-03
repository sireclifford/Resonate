import SwiftUI

struct HomeCategoriesSection: View {

    let categories: [HymnCategory]
    let counts: [HymnCategory: Int]
    let onSeeAll: () -> Void
    let environment: AppEnvironment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Topics")
                    .font(.josefin(size: 18, weight: .semibold))

                Spacer()

                Button(action: onSeeAll) {
                Text("See All")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 8) {
                ForEach(categories.prefix(5)) { category in
                    NavigationLink(value: category) {
                        CategoryRow(
                            title: category.title,
                            count: counts[category] ?? 0,
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

