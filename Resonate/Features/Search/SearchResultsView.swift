import SwiftUI

struct SearchResultsView: View {

    let environment: AppEnvironment
    @ObservedObject var viewModel: SearchViewModel
    let onSelectHymn: (HymnIndex) -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack {
            searchField
            List(viewModel.results) { result in
                Button {
                    onSelectHymn(result.hymn)
                    viewModel.reset()
                    
                } label: {
                    SearchResultRow(result: result)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Search")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFocused = true
            }
        }
    }

    private var searchField: some View {
        TextField("Search hymns, numbers, lyrics…", text: $viewModel.query)
            .focused($isSearchFocused)
            .textFieldStyle(.roundedBorder)
            .padding()
    }
}
