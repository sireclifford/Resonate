import SwiftUI

struct HymnDetailView: View {

    @StateObject private var viewModel: HymnDetailViewModel

    init(hymn: Hymn) {
        _viewModel = StateObject(wrappedValue: HymnDetailViewModel(hymn: hymn))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // Title
                Text(viewModel.hymn.title)
                    .font(.josefin(size: 26, weight: .semibold))

                // Verses
                ForEach(viewModel.hymn.verses.indices, id: \.self) { index in
                    VerseView(
                        title: "Verse \(index + 1)",
                        lines: viewModel.hymn.verses[index],
                        fontSize: viewModel.fontSize
                    )
                }

                // Chorus
                if let chorus = viewModel.hymn.chorus {
                    VerseView(
                        title: "Chorus",
                        lines: chorus,
                        fontSize: viewModel.fontSize
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Hymn \(viewModel.hymn.id)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ReaderToolbar(
                    onDecreaseFont: viewModel.decreaseFont,
                    onIncreaseFont: viewModel.increaseFont
                )
            }
        }
    }
}
