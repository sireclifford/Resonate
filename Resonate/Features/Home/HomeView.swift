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
        List(viewModel.hymns) { hymn in
            NavigationLink(value: hymn) {
                VStack(alignment: .leading) {
                    Text("\(hymn.id). \(hymn.title)")
                        .font(.headline)
                    Text(hymn.category.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
        }
        .navigationTitle("Hymns")
        .navigationDestination(for: Hymn.self) { hymn in
            HymnDetailView(hymn: hymn)
        }
    }
}
