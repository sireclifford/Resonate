import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: HomeViewModel
    @State private var path = NavigationPath()

    init(environment: AppEnvironment) {
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(hymnService: environment.hymnService)
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                content
            }
//            .navigationTitle("Hymns")
            .navigationDestination(for: Hymn.self) { hymn in
                HymnDetailView(hymn: hymn)
            }
        }
        
    }
    
    
    private var content: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            // Hymn of the Day
            if let hymn = viewModel.hymnOfTheDay {
                HymnOfTheDayHeader(
                    hymn: hymn,
                    onOpen: {
                        // push hymn reader
                        path.append(hymn)
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
                            NavigationLink(value: hymn) {
                                HymnCardView(
                                    hymn: hymn,
                                    isFavourite: true,
                                    onFavouriteToggle: {}
                                ).frame(width: 180)
                            }
                            .buttonStyle(.plain)
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
}


