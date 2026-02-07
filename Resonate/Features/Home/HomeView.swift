import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(hymnService: AppEnvironment().hymnService)
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {

                // Hymn of the Day
                if let hymn = viewModel.hymnOfTheDay {
                    HymnOfTheDayHeader(
                        hymn: hymn,
                        onOpen: {
                            // navigation comes next
                        }
                    )
                }

                // Recently Viewed
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recently Viewed")
                            .font(.headline)
                        Spacer()
                        Text("See all")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.recentlyViewed) { hymn in
                                HymnCardView(
                                    hymn: hymn,
                                    isFavourite: false,
                                    onFavouriteToggle: {}
                                )
                                .frame(width: 160)
                            }
                        }
                    }
                }

                // Classification (placeholder)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Classification")
                            .font(.headline)
                        Spacer()
                        Text("See all")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Categories coming next")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Hymns")
    }
}
