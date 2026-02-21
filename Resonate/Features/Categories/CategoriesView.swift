import SwiftUI

struct CategoriesView: View {
    
    let environment: AppEnvironment
    @StateObject private var viewModel: CategoryViewModel
    
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
            .scrollIndicators(.hidden)
            .navigationTitle("Topics")
        }
    }
