import Combine

final class CategoryViewModel: ObservableObject {

    @Published var categories: [HymnCategory] = []
    @Published var hymnsByCategory: [HymnCategory: [Hymn]] = [:]

    private let hymnService: HymnService

    init(hymnService: HymnService) {
        self.hymnService = hymnService
        load()
    }

    private func load() {
        let hymns = hymnService.hymns

        let grouped = Dictionary(grouping: hymns, by: \.category)

        // Exclude empty + uncategorized (optional)
        let sortedCategories = grouped
            .filter { !$0.value.isEmpty }
            .map { $0.key }
            .sorted { $0.title < $1.title }

        self.categories = sortedCategories
        self.hymnsByCategory = grouped
    }

    func hymns(for category: HymnCategory) -> [Hymn] {
        hymnsByCategory[category] ?? []
    }
}
