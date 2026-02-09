import SwiftUI

struct SearchResultsView: View {

    let environment: AppEnvironment
    @ObservedObject var viewModel: SearchViewModel
    let onSelectHymn: (Hymn) -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack {
            searchField

            List(viewModel.results) { result in
                Button {
                    onSelectHymn(result.hymn)
                } label: {
                    SearchResultRow(result: result)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Search")
        .onAppear {
            isSearchFocused = true
        }
    }

    private var searchField: some View {
        TextField("Search hymns, numbers, lyrics…", text: $viewModel.query)
            .textFieldStyle(.roundedBorder)
            .padding()
            .focused($isSearchFocused)
    }
}
