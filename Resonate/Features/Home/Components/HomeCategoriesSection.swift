import SwiftUI

struct HomeCategoriesSection: View {

    let categories: [HymnCategory]
    let counts: [HymnCategory: Int]
//    let onSeeAll: () -> Void
    let onSelect: (HymnCategory) -> Void
    let environment: AppEnvironment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Topics")
                    .font(.josefin(size: 18, weight: .semibold))

                Spacer()

                NavigationLink {
                            CategoriesView(environment: environment)
                        } label: {
                            Text("See All")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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

