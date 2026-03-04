import SwiftUI

struct VerseSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    let verseIndex: Int

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Spacer()

                Text("Verse \(verseIndex + 1)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Text(viewModel.lines(for: verseIndex).joined(separator: "\n"))
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(10)

                Spacer()

                // Optional tiny hint / duration chips
                HStack(spacing: 10) {
                    chip("2 min sing")
                    chip("1 min reflect")
                }

                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 40)
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.12))
            .clipShape(Capsule())
    }
}
