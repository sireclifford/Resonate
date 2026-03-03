import SwiftUI

struct GlobalSearchBar: View {

    @ObservedObject var viewModel: SearchViewModel
    let onActivate: () -> Void

    var body: some View {
        Button {
            onActivate()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                Text(
                    viewModel.query.isEmpty
                    ? "Search hymns, numbers, lyrics…"
                    : viewModel.query
                )
                .foregroundColor(
                    viewModel.query.isEmpty ? .secondary : .primary
                )

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}
