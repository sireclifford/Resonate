import SwiftUI

struct VerseSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    let verseIndex: Int

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Verse \(verseIndex + 1) of \(max(viewModel.verseCount, 1))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer(minLength: 12)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(viewModel.lines(for: verseIndex).enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 34, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)
                            .lineSpacing(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                HStack(spacing: 10) {
                    chip("2 min sing")
                    chip("1 min reflect")
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 80)
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

struct ChorusSlide: View {
    @ObservedObject var viewModel: DevotionViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text("Chorus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer(minLength: 12)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array((viewModel.detail?.chorus ?? []).enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 36, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .lineSpacing(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                HStack(spacing: 10) {
                    Text("Sing the refrain")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 80)
            .padding(.bottom, 40)
        }
    }
}
