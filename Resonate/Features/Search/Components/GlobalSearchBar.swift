import SwiftUI

struct GlobalSearchBar: View {
    @ObservedObject var viewModel: SearchViewModel
    let onActivate: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            onActivate()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(PremiumTheme.scaledSystem(size: 13, weight: .semibold))
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

                Text(
                    viewModel.query.isEmpty
                    ? "Search hymns, numbers, lyrics…"
                    : viewModel.query
                )
                .font(PremiumTheme.scaledSystem(size: 14, weight: .medium))
                .foregroundStyle(
                    viewModel.query.isEmpty
                    ? PremiumTheme.secondaryText(for: colorScheme)
                    : PremiumTheme.primaryText(for: colorScheme)
                )

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(PremiumTheme.searchFieldFill(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: PremiumTheme.shadow(for: colorScheme).opacity(0.26), radius: 7, y: 3)
        }
        .buttonStyle(.plain)
    }
}
