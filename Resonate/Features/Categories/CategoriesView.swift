import SwiftUI

struct CategoriesView: View {

    let environment: AppEnvironment
    @StateObject private var viewModel: CategoryViewModel
    @State private var path = NavigationPath()

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: CategoryViewModel(
                hymnService: environment.hymnService
            )
        )
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.categories) { category in
                        NavigationLink(value: category) {
                            CategoryCardView(
                                category: category,
                                count: viewModel.hymns(for: category).count
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
            .navigationDestination(for: HymnCategory.self) { category in
                CategoryDetailView(
                    category: category,
                    hymns: viewModel.hymns(for: category),
                    environment: environment
                )
            }
        }
    }
}
